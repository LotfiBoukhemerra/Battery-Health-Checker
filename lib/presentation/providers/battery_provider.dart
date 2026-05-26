import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/windows_notification_service.dart';
import '../../data/datasources/windows_battery_data_source.dart';
import '../../domain/entities/battery_info.dart';
import '../../domain/repositories/battery_repository.dart';
import 'alerts_provider.dart';

/// ChangeNotifier managing battery information state.
///
/// - Fetches battery info on demand or periodically.
/// - Caches the powercfg report and only refreshes
///   real-time level on each periodic tick.
/// - Checks alert thresholds and fires notifications.
class BatteryProvider extends ChangeNotifier {
  final BatteryRepository _repository;
  final AlertsProvider _alertsProvider;
  final WindowsNotificationService _notificationService;

  BatteryInfo? _batteryInfo;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isNoBattery = false;
  bool _isVirtualBattery = false;
  Timer? _refreshTimer;

  BatteryProvider({
    required BatteryRepository repository,
    required AlertsProvider alertsProvider,
    required WindowsNotificationService notificationService,
  }) : _repository = repository,
       _alertsProvider = alertsProvider,
       _notificationService = notificationService;

  BatteryInfo? get batteryInfo => _batteryInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isNoBattery => _isNoBattery;
  bool get isVirtualBattery => _isVirtualBattery;
  bool get hasData => _batteryInfo != null;

  /// Fetches battery info. First call runs the full
  /// powercfg report; subsequent calls use cached data
  /// unless [forceRefreshReport] is true.
  Future<void> fetchBatteryInfo({bool forceRefreshReport = false}) async {
    if (_isLoading) return;

    _isLoading = _batteryInfo == null;
    _errorMessage = null;
    notifyListeners();

    try {
      _batteryInfo = await _repository.getBatteryInfo(
        forceRefreshReport: forceRefreshReport,
      );
      _isNoBattery = false;
      _isVirtualBattery = false;
      _errorMessage = null;
      _checkAlerts();
    } on NoBatteryException {
      _isNoBattery = true;
      _isVirtualBattery = false;
      _errorMessage = 'No battery detected';
      // No point in polling when there is no battery.
      stopPeriodicRefresh();
    } on VirtualBatteryException {
      _isVirtualBattery = true;
      _isNoBattery = false;
      _errorMessage = 'Virtual battery detected';
      // Virtual batteries don't change — stop polling.
      stopPeriodicRefresh();
    } on BatteryReportException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      debugPrint('Failed to fetch battery info: $e');
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Starts periodic refresh (level-only, no report).
  void startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      AppConstants.refreshInterval,
      (_) => fetchBatteryInfo(),
    );
    // Fetch immediately with full report on first call.
    fetchBatteryInfo(forceRefreshReport: true);
  }

  /// Stops periodic refresh.
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Manually refreshes (re-runs powercfg).
  Future<void> refresh() async {
    await fetchBatteryInfo(forceRefreshReport: true);
  }

  /// Checks battery level against user thresholds
  /// and shows notifications when needed.
  ///
  /// Reads settings from the already-loaded
  /// [AlertsProvider] instead of hitting
  /// SharedPreferences on every tick.
  void _checkAlerts() {
    final info = _batteryInfo;
    if (info == null) return;

    final lowThreshold = _alertsProvider.lowThreshold;
    final highThreshold = _alertsProvider.highThreshold;
    final lowEnabled = _alertsProvider.lowAlertEnabled;
    final highEnabled = _alertsProvider.highAlertEnabled;

    // Low battery alert
    if (lowEnabled && info.level <= lowThreshold && !info.isCharging) {
      if (!_notificationService.lowAlertFired) {
        _notificationService.lowAlertFired = true;
        _notificationService.showLowBatteryAlert(level: info.level);
      }
    } else {
      _notificationService.lowAlertFired = false;
    }

    // High battery alert
    if (highEnabled && info.level >= highThreshold && info.isCharging) {
      if (!_notificationService.highAlertFired) {
        _notificationService.highAlertFired = true;
        _notificationService.showHighBatteryAlert(level: info.level);
      }
    } else {
      _notificationService.highAlertFired = false;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
