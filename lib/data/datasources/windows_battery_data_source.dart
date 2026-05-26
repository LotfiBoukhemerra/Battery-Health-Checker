import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;

import '../../domain/entities/battery_info.dart';

/// Data source that retrieves battery information on
/// Windows by running `powercfg /batteryreport` and
/// parsing the generated HTML report.
///
/// Real-time charge level and charging state come from
/// the [battery_plus] package.
class WindowsBatteryDataSource {
  final Battery _battery = Battery();

  /// Cached report data so we don't re-run powercfg
  /// on every periodic refresh.
  _ReportData? _cachedReport;

  /// Fetches battery info, combining real-time level
  /// with cached or fresh report data.
  ///
  /// Set [forceRefreshReport] to re-run powercfg.
  Future<BatteryInfo> getBatteryInfo({bool forceRefreshReport = false}) async {
    // Parse the battery report first (cached or fresh).
    // This detects "no battery" via the HTML report before
    // querying battery_plus, which may throw on systems
    // without a battery.
    if (_cachedReport == null || forceRefreshReport) {
      _cachedReport = await _parseBatteryReport();
    }

    // Get real-time data from battery_plus.
    // On systems without a battery, battery_plus throws
    // a PlatformException (GetSystemPowerStatus() failed).
    int level;
    bool isCharging;
    try {
      level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      isCharging = state == BatteryState.charging || state == BatteryState.full;
    } on PlatformException {
      throw NoBatteryException();
    }

    final report = _cachedReport!;
    return BatteryInfo(
      level: level,
      isCharging: isCharging,
      designCapacityMwh: report.designCapacity,
      fullChargeCapacityMwh: report.fullChargeCapacity,
      name: report.name,
      manufacturer: report.manufacturer,
      serialNumber: report.serialNumber,
      chemistry: report.chemistry,
      cycleCount: report.cycleCount,
    );
  }
  /// Runs `powercfg /batteryreport` and parses the
  /// generated HTML file.
  Future<_ReportData> _parseBatteryReport() async {
    final tempDir = Directory.systemTemp;
    final reportPath = '${tempDir.path}\\battery-report.html';

    // Run powercfg — does NOT need admin privileges when
    // specifying an output path in a writable directory.
    final result = await Process.run('powercfg', [
      '/batteryreport',
      '/output',
      reportPath,
    ], runInShell: true);

    if (result.exitCode != 0) {
      final stderr = result.stderr.toString();
      if (stderr.contains('no battery') ||
          stderr.contains('not present') ||
          result.stdout.toString().contains('no battery')) {
        throw NoBatteryException();
      }
      throw BatteryReportException(
        'powercfg failed (exit ${result.exitCode}): '
        '${result.stderr}',
      );
    }

    final file = File(reportPath);
    if (!await file.exists()) {
      throw BatteryReportException('Battery report file was not generated.');
    }

    final htmlContent = await file.readAsString();

    // Clean up the temporary report file.
    try {
      await file.delete();
    } catch (_) {}

    return _parseHtml(htmlContent);
  }

  /// Extracts battery metadata and capacity values from
  /// the powercfg HTML report.
  ///
  /// The HTML structure has an "Installed batteries"
  /// section with a table containing labeled rows:
  /// ```
  /// <tr>
  ///   <td><span class="label">NAME</span></td>
  ///   <td>DELL 2X39G</td>
  /// </tr>
  /// ```
  _ReportData _parseHtml(String htmlContent) {
    final document = html_parser.parse(htmlContent);

    // Find the "Installed batteries" heading
    final h2Elements = document.querySelectorAll('h2');
    var batteryTableFound = false;

    String name = 'Unknown';
    String manufacturer = 'Unknown';
    String serialNumber = 'Unknown';
    String chemistry = 'Unknown';
    String cycleCount = '-';
    int designCapacity = 0;
    int fullChargeCapacity = 0;

    for (final h2 in h2Elements) {
      if (h2.text.trim().contains('Installed batteries')) {
        batteryTableFound = true;

        // Check for "No batteries are currently installed"
        // message which uses a span with class "nobatts".
        var sibling = h2.nextElementSibling;
        while (sibling != null) {
          // When no battery is installed, the report
          // contains: <span class="nobatts">No batteries
          // are currently installed</span>
          final nobatts = sibling.querySelector('.nobatts');
          if (nobatts != null) {
            throw NoBatteryException();
          }

          if (sibling.localName == 'table') {
            // Parse rows with label spans.
            final rows = sibling.querySelectorAll('tr');
            for (final row in rows) {
              final labelSpan = row.querySelector('span.label');
              if (labelSpan == null) continue;

              final label = labelSpan.text.trim().toUpperCase();
              final cells = row.querySelectorAll('td');
              if (cells.length < 2) continue;

              final value = cells[1].text.trim();

              switch (label) {
                case 'NAME':
                  name = value;
                case 'MANUFACTURER':
                  manufacturer = value;
                case 'SERIAL NUMBER':
                  serialNumber = value;
                case 'CHEMISTRY':
                  chemistry = value;
                case 'DESIGN CAPACITY':
                  designCapacity = _parseMwh(value);
                case 'FULL CHARGE CAPACITY':
                  fullChargeCapacity = _parseMwh(value);
                case 'CYCLE COUNT':
                  cycleCount = value.isEmpty ? '-' : value;
              }
            }
            break;
          }
          sibling = sibling.nextElementSibling;
        }
        break;
      }
    }

    if (!batteryTableFound) {
      throw NoBatteryException();
    }

    if (designCapacity == 0 && fullChargeCapacity == 0) {
      throw NoBatteryException();
    }

    // Detect virtual machine batteries that report
    // synthetic/unreliable data.
    if (_isVirtualBattery(name)) {
      throw VirtualBatteryException();
    }

    return _ReportData(
      name: name,
      manufacturer: manufacturer,
      serialNumber: serialNumber,
      chemistry: chemistry,
      cycleCount: cycleCount,
      designCapacity: designCapacity,
      fullChargeCapacity: fullChargeCapacity,
    );
  }

  /// Parses a capacity string like "42,920 mWh" or
  /// "50 510 mWh" to an integer value.
  ///
  /// Some Windows locales use Narrow No-Break Space
  /// (U+202F) as the thousands separator instead of
  /// a comma. We strip ALL non-digit characters.
  int _parseMwh(String value) {
    final digitsOnly = value
        .replaceAll('mWh', '')
        .runes
        .where((c) => c >= 48 && c <= 57)
        .map((c) => String.fromCharCode(c))
        .join();
    return int.tryParse(digitsOnly) ?? 0;
  }

  /// Checks whether the battery name matches a known
  /// virtual machine battery identifier.
  static bool _isVirtualBattery(String name) {
    final lower = name.toLowerCase();
    const virtualNames = [
      'hyper-v',
      'vmware',
      'virtualbox',
      'qemu',
      'parallels',
      'virtual battery',
      'xen',
    ];
    return virtualNames.any((v) => lower.contains(v));
  }
}

/// Internal data holder for parsed report values.
class _ReportData {
  final String name;
  final String manufacturer;
  final String serialNumber;
  final String chemistry;
  final String cycleCount;
  final int designCapacity;
  final int fullChargeCapacity;

  const _ReportData({
    required this.name,
    required this.manufacturer,
    required this.serialNumber,
    required this.chemistry,
    required this.cycleCount,
    required this.designCapacity,
    required this.fullChargeCapacity,
  });
}

/// Thrown when no battery is detected on the system.
class NoBatteryException implements Exception {
  @override
  String toString() => 'No battery detected on this device';
}

/// Thrown when a virtual machine battery is detected
/// (e.g. Microsoft Hyper-V Virtual Battery).
///
/// Virtual batteries report synthetic data that does
/// not reflect real hardware.
class VirtualBatteryException implements Exception {
  @override
  String toString() =>
      'Virtual battery detected — real battery '
      'data is unavailable';
}

/// Thrown when the battery report could not be generated
/// or parsed.
class BatteryReportException implements Exception {
  final String message;
  BatteryReportException(this.message);

  @override
  String toString() => message;
}
