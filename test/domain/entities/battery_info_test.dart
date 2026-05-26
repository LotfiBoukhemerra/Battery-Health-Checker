import 'package:battery_checker/core/constants/app_colors.dart';
import 'package:battery_checker/domain/entities/battery_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BatteryInfo', () {
    group('healthPercent', () {
      test('returns correct percentage for normal values', () {
        const info = BatteryInfo(
          level: 85,
          isCharging: false,
          designCapacityMwh: 50000,
          fullChargeCapacityMwh: 45000,
        );

        expect(info.healthPercent, 90.0);
      });

      test('returns 100 when full charge equals design', () {
        const info = BatteryInfo(
          level: 100,
          isCharging: true,
          designCapacityMwh: 40000,
          fullChargeCapacityMwh: 40000,
        );

        expect(info.healthPercent, 100.0);
      });

      test('clamps to 100 when full charge exceeds design', () {
        const info = BatteryInfo(
          level: 100,
          isCharging: true,
          designCapacityMwh: 40000,
          fullChargeCapacityMwh: 45000,
        );

        expect(info.healthPercent, 100.0);
      });

      test('returns 0 when design capacity is zero', () {
        const info = BatteryInfo(
          level: 50,
          isCharging: false,
          designCapacityMwh: 0,
          fullChargeCapacityMwh: 30000,
        );

        expect(info.healthPercent, 0.0);
      });

      test('returns 0 when design capacity is negative', () {
        const info = BatteryInfo(
          level: 50,
          isCharging: false,
          designCapacityMwh: -1,
          fullChargeCapacityMwh: 30000,
        );

        expect(info.healthPercent, 0.0);
      });

      test('handles very degraded battery', () {
        const info = BatteryInfo(
          level: 20,
          isCharging: false,
          designCapacityMwh: 50000,
          fullChargeCapacityMwh: 10000,
        );

        expect(info.healthPercent, 20.0);
      });
    });

    group('healthStatus', () {
      test('returns excellent for >= 90%', () {
        const info = BatteryInfo(
          level: 100,
          isCharging: false,
          designCapacityMwh: 50000,
          fullChargeCapacityMwh: 46000,
        );

        expect(info.healthStatus, 'health_excellent');
      });

      test('returns good for 70-89%', () {
        const info = BatteryInfo(
          level: 80,
          isCharging: false,
          designCapacityMwh: 50000,
          fullChargeCapacityMwh: 40000,
        );

        expect(info.healthStatus, 'health_good');
      });

      test('returns moderate for 50-69%', () {
        const info = BatteryInfo(
          level: 60,
          isCharging: false,
          designCapacityMwh: 50000,
          fullChargeCapacityMwh: 30000,
        );

        expect(info.healthStatus, 'health_moderate');
      });

      test('returns warning for 30-49%', () {
        const info = BatteryInfo(
          level: 40,
          isCharging: false,
          designCapacityMwh: 50000,
          fullChargeCapacityMwh: 20000,
        );

        expect(info.healthStatus, 'health_warning');
      });

      test('returns critical for < 30%', () {
        const info = BatteryInfo(
          level: 10,
          isCharging: false,
          designCapacityMwh: 50000,
          fullChargeCapacityMwh: 10000,
        );

        expect(info.healthStatus, 'health_critical');
      });
    });

    group('healthColor', () {
      test('returns healthExcellent for >= 90%', () {
        const info = BatteryInfo(
          level: 100,
          isCharging: false,
          designCapacityMwh: 100,
          fullChargeCapacityMwh: 95,
        );

        expect(info.healthColor, AppColors.healthExcellent);
      });

      test('returns healthCritical for < 30%', () {
        const info = BatteryInfo(
          level: 10,
          isCharging: false,
          designCapacityMwh: 100,
          fullChargeCapacityMwh: 20,
        );

        expect(info.healthColor, AppColors.healthCritical);
      });
    });

    group('formatCapacity', () {
      test('formats normal capacity with comma separator', () {
        expect(BatteryInfo.formatCapacity(42920), '42,920 mWh');
      });

      test('formats large capacity', () {
        expect(BatteryInfo.formatCapacity(100000), '100,000 mWh');
      });

      test('formats small capacity without comma', () {
        expect(BatteryInfo.formatCapacity(500), '500 mWh');
      });

      test('returns dash for zero capacity', () {
        expect(BatteryInfo.formatCapacity(0), '-');
      });

      test('returns dash for negative capacity', () {
        expect(BatteryInfo.formatCapacity(-100), '-');
      });

      test('formats capacity exactly 1000', () {
        expect(BatteryInfo.formatCapacity(1000), '1,000 mWh');
      });

      test('formats six-digit capacity', () {
        expect(BatteryInfo.formatCapacity(123456), '123,456 mWh');
      });
    });

    group('default values', () {
      test('uses sensible defaults for optional fields', () {
        const info = BatteryInfo(
          level: 50,
          isCharging: false,
          designCapacityMwh: 40000,
          fullChargeCapacityMwh: 35000,
        );

        expect(info.name, 'Unknown');
        expect(info.manufacturer, 'Unknown');
        expect(info.serialNumber, 'Unknown');
        expect(info.chemistry, 'Unknown');
        expect(info.cycleCount, '-');
      });
    });
  });
}
