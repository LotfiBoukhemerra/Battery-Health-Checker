import 'package:battery_checker/core/constants/app_colors.dart';
import 'package:battery_checker/core/utils/battery_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BatteryUtils', () {
    group('getChargingStatusText', () {
      test('returns "Charging" when charging', () {
        expect(
          BatteryUtils.getChargingStatusText(true),
          'Charging',
        );
      });

      test('returns "Not Charging" when not charging', () {
        expect(
          BatteryUtils.getChargingStatusText(false),
          'Not Charging',
        );
      });
    });

    group('getHealthColor', () {
      test('returns healthExcellent for 100%', () {
        expect(
          BatteryUtils.getHealthColor(100),
          AppColors.healthExcellent,
        );
      });

      test('returns healthExcellent for 90%', () {
        expect(
          BatteryUtils.getHealthColor(90),
          AppColors.healthExcellent,
        );
      });

      test('returns healthGood for 70%', () {
        expect(
          BatteryUtils.getHealthColor(70),
          AppColors.healthGood,
        );
      });

      test('returns healthModerate for 50%', () {
        expect(
          BatteryUtils.getHealthColor(50),
          AppColors.healthModerate,
        );
      });

      test('returns healthWarning for 30%', () {
        expect(
          BatteryUtils.getHealthColor(30),
          AppColors.healthWarning,
        );
      });

      test('returns healthCritical for 29%', () {
        expect(
          BatteryUtils.getHealthColor(29),
          AppColors.healthCritical,
        );
      });

      test('returns healthCritical for 0%', () {
        expect(
          BatteryUtils.getHealthColor(0),
          AppColors.healthCritical,
        );
      });
    });

    group('getHealthStatusText', () {
      test('returns "Excellent" for >= 90%', () {
        expect(BatteryUtils.getHealthStatusText(95), 'Excellent');
      });

      test('returns "Good" for 70-89%', () {
        expect(BatteryUtils.getHealthStatusText(75), 'Good');
      });

      test('returns "Moderate" for 50-69%', () {
        expect(BatteryUtils.getHealthStatusText(55), 'Moderate');
      });

      test('returns "Needs Attention" for 30-49%', () {
        expect(BatteryUtils.getHealthStatusText(35), 'Needs Attention');
      });

      test('returns "Replace Soon" for < 30%', () {
        expect(BatteryUtils.getHealthStatusText(10), 'Replace Soon');
      });

      test('boundary: exactly 90% is Excellent', () {
        expect(BatteryUtils.getHealthStatusText(90), 'Excellent');
      });

      test('boundary: exactly 70% is Good', () {
        expect(BatteryUtils.getHealthStatusText(70), 'Good');
      });

      test('boundary: exactly 50% is Moderate', () {
        expect(BatteryUtils.getHealthStatusText(50), 'Moderate');
      });

      test('boundary: exactly 30% is Needs Attention', () {
        expect(BatteryUtils.getHealthStatusText(30), 'Needs Attention');
      });
    });
  });
}
