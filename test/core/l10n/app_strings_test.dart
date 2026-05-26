import 'package:battery_checker/core/l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppStrings', () {
    setUp(() async {
      // Set up fake SharedPreferences for testing.
      SharedPreferences.setMockInitialValues({});
      await AppStrings.init();
    });

    group('tr', () {
      test('returns English string by default', () {
        expect(AppStrings.tr('app_name'), 'Battery Checker');
      });

      test('returns key itself when key not found', () {
        expect(AppStrings.tr('nonexistent_key'), 'nonexistent_key');
      });

      test('translates battery screen keys', () {
        expect(AppStrings.tr('battery'), 'Battery');
        expect(AppStrings.tr('alerts'), 'Alerts');
        expect(AppStrings.tr('settings'), 'Settings');
      });

      test('translates health status keys', () {
        expect(AppStrings.tr('health_excellent'), isNotEmpty);
        expect(AppStrings.tr('health_good'), isNotEmpty);
        expect(AppStrings.tr('health_moderate'), isNotEmpty);
        expect(AppStrings.tr('health_warning'), isNotEmpty);
        expect(AppStrings.tr('health_critical'), isNotEmpty);
      });

      test('translates error keys', () {
        expect(AppStrings.tr('error_no_battery'), isNotEmpty);
        expect(AppStrings.tr('error_title'), isNotEmpty);
      });
    });

    group('trWithParam', () {
      test('replaces single parameter', () {
        final result = AppStrings.trWithParam(
          'version',
          'version',
          '2.0.0',
        );

        expect(result, 'Version 2.0.0');
      });

      test('replaces low battery description param', () {
        final result = AppStrings.trWithParam(
          'low_battery_desc',
          'value',
          '15',
        );

        expect(result, contains('15%'));
      });

      test('replaces full charge description param', () {
        final result = AppStrings.trWithParam(
          'full_charge_desc',
          'value',
          '90',
        );

        expect(result, contains('90%'));
      });
    });

    group('locale management', () {
      test('defaults to English locale', () {
        expect(AppStrings.currentLocale.languageCode, 'en');
      });

      test('isRtl returns false for English', () {
        expect(AppStrings.isRtl, isFalse);
      });

      test('setLocale switches to Arabic', () async {
        await AppStrings.setLocale(const Locale('ar'));

        expect(AppStrings.currentLocale.languageCode, 'ar');
        expect(AppStrings.isRtl, isTrue);
        expect(AppStrings.tr('app_name'), 'فاحص البطارية');
      });

      test('setLocale switches to Spanish', () async {
        await AppStrings.setLocale(const Locale('es'));

        expect(AppStrings.currentLocale.languageCode, 'es');
        expect(AppStrings.isRtl, isFalse);
        expect(AppStrings.tr('battery'), 'Batería');
      });

      test('falls back to English for unknown locale', () async {
        await AppStrings.setLocale(const Locale('ja'));

        // Should fall back to English since 'ja' has
        // no translations.
        expect(AppStrings.tr('app_name'), 'Battery Checker');
      });

      test('Arabic translations exist for core keys', () async {
        await AppStrings.setLocale(const Locale('ar'));

        expect(AppStrings.tr('battery'), 'البطارية');
        expect(AppStrings.tr('alerts'), 'التنبيهات');
        expect(AppStrings.tr('settings'), 'الإعدادات');
        expect(AppStrings.tr('charging'), 'يتم الشحن');
      });

      test('Spanish translations exist for core keys', () async {
        await AppStrings.setLocale(const Locale('es'));

        expect(AppStrings.tr('battery'), 'Batería');
        expect(AppStrings.tr('alerts'), 'Alertas');
        expect(AppStrings.tr('settings'), 'Configuración');
        expect(AppStrings.tr('charging'), 'Cargando');
      });
    });

    group('supportedLocales', () {
      test('contains exactly 3 locales', () {
        expect(AppStrings.supportedLocales, hasLength(3));
      });

      test('includes en, ar, es', () {
        final codes = AppStrings.supportedLocales
            .map((l) => l.languageCode)
            .toList();

        expect(codes, containsAll(['en', 'ar', 'es']));
      });
    });

    group('localeNames', () {
      test('maps en to English', () {
        expect(AppStrings.localeNames['en'], 'English');
      });

      test('maps ar to العربية', () {
        expect(AppStrings.localeNames['ar'], 'العربية');
      });

      test('maps es to Español', () {
        expect(AppStrings.localeNames['es'], 'Español');
      });

      test('has entry for each supported locale', () {
        for (final locale in AppStrings.supportedLocales) {
          expect(
            AppStrings.localeNames,
            containsPair(locale.languageCode, isNotEmpty),
          );
        }
      });
    });
  });
}
