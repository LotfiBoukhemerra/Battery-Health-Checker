import 'package:battery_checker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    group('getBatteryColor', () {
      test('returns grey for null level', () {
        expect(AppColors.getBatteryColor(null), Colors.grey);
      });

      test('returns batteryHigh for level > 60', () {
        expect(AppColors.getBatteryColor(61), AppColors.batteryHigh);
        expect(AppColors.getBatteryColor(100), AppColors.batteryHigh);
      });

      test('returns batteryMedium for 21-60', () {
        expect(AppColors.getBatteryColor(21), AppColors.batteryMedium);
        expect(AppColors.getBatteryColor(60), AppColors.batteryMedium);
        expect(AppColors.getBatteryColor(40), AppColors.batteryMedium);
      });

      test('returns batteryLow for <= 20', () {
        expect(AppColors.getBatteryColor(20), AppColors.batteryLow);
        expect(AppColors.getBatteryColor(10), AppColors.batteryLow);
        expect(AppColors.getBatteryColor(0), AppColors.batteryLow);
      });
    });

    group('getHealthColor', () {
      test('returns healthExcellent for >= 90%', () {
        expect(AppColors.getHealthColor(90), AppColors.healthExcellent);
        expect(AppColors.getHealthColor(100), AppColors.healthExcellent);
      });

      test('returns healthGood for 70-89%', () {
        expect(AppColors.getHealthColor(70), AppColors.healthGood);
        expect(AppColors.getHealthColor(89), AppColors.healthGood);
      });

      test('returns healthModerate for 50-69%', () {
        expect(AppColors.getHealthColor(50), AppColors.healthModerate);
        expect(AppColors.getHealthColor(69), AppColors.healthModerate);
      });

      test('returns healthWarning for 30-49%', () {
        expect(AppColors.getHealthColor(30), AppColors.healthWarning);
        expect(AppColors.getHealthColor(49), AppColors.healthWarning);
      });

      test('returns healthCritical for < 30%', () {
        expect(AppColors.getHealthColor(29), AppColors.healthCritical);
        expect(AppColors.getHealthColor(0), AppColors.healthCritical);
      });
    });

    group('color consistency', () {
      test('primary matches gradientStart and waveColor', () {
        expect(AppColors.primary, AppColors.gradientStart);
        expect(AppColors.primary, AppColors.waveColor);
      });

      test('primary matches batteryHigh and success', () {
        expect(AppColors.primary, AppColors.batteryHigh);
        expect(AppColors.primary, AppColors.success);
      });

      test('dark theme colors are darker than light', () {
        // Dark background should have a lower luminance
        final darkLum = AppColors.darkBackground.computeLuminance();
        final lightLum = AppColors.lightBackground.computeLuminance();
        expect(darkLum, lessThan(lightLum));
      });
    });
  });
}
