import '../../domain/entities/battery_info.dart';

/// Abstract repository interface for battery operations.
abstract class BatteryRepository {
  /// Fetches current battery information.
  ///
  /// Set [forceRefreshReport] to re-run the powercfg
  /// command and re-parse the battery report.
  Future<BatteryInfo> getBatteryInfo({bool forceRefreshReport = false});
}
