import 'package:battery_checker/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConstants', () {
    test('appVersion follows semver', () {
      final parts = AppConstants.appVersion.split('.');
      expect(parts, hasLength(3));
      for (final part in parts) {
        expect(int.tryParse(part), isNotNull);
      }
    });

    test('URLs are valid', () {
      for (final url in [
        AppConstants.websiteUrl,
        AppConstants.kofiUrl,
        AppConstants.paypalUrl,
        AppConstants.privacyUrl,
      ]) {
        expect(Uri.tryParse(url)?.hasScheme, isTrue);
      }
    });

    test('default thresholds are in valid ranges', () {
      expect(AppConstants.defaultLowThreshold, inInclusiveRange(5, 45));
      expect(AppConstants.defaultHighThreshold, inInclusiveRange(50, 100));
      expect(
        AppConstants.defaultLowThreshold,
        lessThan(AppConstants.defaultHighThreshold),
      );
    });

    test('window constraints are valid', () {
      expect(AppConstants.minWindowWidth, greaterThan(0));
      expect(AppConstants.minWindowHeight, greaterThan(0));
      expect(AppConstants.windowHeightScreenRatio, inInclusiveRange(0.0, 1.0));
    });

    test('refresh interval is reasonable', () {
      expect(AppConstants.refreshInterval.inSeconds, greaterThanOrEqualTo(10));
      expect(AppConstants.refreshInterval.inMinutes, lessThanOrEqualTo(5));
    });

    test('SharedPreferences keys are unique', () {
      final keys = [
        AppConstants.themeKey,
        AppConstants.lowThresholdKey,
        AppConstants.highThresholdKey,
        AppConstants.lowAlertEnabledKey,
        AppConstants.highAlertEnabledKey,
        AppConstants.minimizeToTrayKey,
        AppConstants.startWithWindowsKey,
        AppConstants.localeKey,
      ];
      expect(keys.toSet().length, keys.length);
    });
  });
}
