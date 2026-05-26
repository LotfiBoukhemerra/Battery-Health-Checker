import '../../domain/entities/battery_info.dart';
import '../../domain/repositories/battery_repository.dart';
import '../datasources/windows_battery_data_source.dart';

/// Implementation of [BatteryRepository] that delegates
/// to the Windows battery data source.
class BatteryRepositoryImpl implements BatteryRepository {
  final WindowsBatteryDataSource dataSource;

  BatteryRepositoryImpl({required this.dataSource});

  @override
  Future<BatteryInfo> getBatteryInfo({bool forceRefreshReport = false}) async {
    return dataSource.getBatteryInfo(forceRefreshReport: forceRefreshReport);
  }
}
