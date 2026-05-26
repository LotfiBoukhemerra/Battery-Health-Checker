import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/repositories/settings_repository.dart';

/// Implementation of [SettingsRepository] using
/// SharedPreferences for local persistence.
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences prefs;

  SettingsRepositoryImpl({required this.prefs});

  @override
  Future<int> getLowThreshold() async {
    return prefs.getInt(AppConstants.lowThresholdKey) ??
        AppConstants.defaultLowThreshold;
  }

  @override
  Future<int> getHighThreshold() async {
    return prefs.getInt(AppConstants.highThresholdKey) ??
        AppConstants.defaultHighThreshold;
  }

  @override
  Future<bool> isLowAlertEnabled() async {
    return prefs.getBool(AppConstants.lowAlertEnabledKey) ?? true;
  }

  @override
  Future<bool> isHighAlertEnabled() async {
    return prefs.getBool(AppConstants.highAlertEnabledKey) ?? true;
  }

  @override
  Future<void> setLowThreshold(int value) async {
    await prefs.setInt(AppConstants.lowThresholdKey, value);
  }

  @override
  Future<void> setHighThreshold(int value) async {
    await prefs.setInt(AppConstants.highThresholdKey, value);
  }

  @override
  Future<void> setLowAlertEnabled(bool value) async {
    await prefs.setBool(AppConstants.lowAlertEnabledKey, value);
  }

  @override
  Future<void> setHighAlertEnabled(bool value) async {
    await prefs.setBool(AppConstants.highAlertEnabledKey, value);
  }

  @override
  Future<bool> isMinimizeToTrayEnabled() async {
    return prefs.getBool(AppConstants.minimizeToTrayKey) ?? false;
  }

  @override
  Future<void> setMinimizeToTrayEnabled(bool value) async {
    await prefs.setBool(AppConstants.minimizeToTrayKey, value);
  }

  @override
  Future<bool> isStartWithWindowsEnabled() async {
    return prefs.getBool(AppConstants.startWithWindowsKey) ?? false;
  }

  @override
  Future<void> setStartWithWindowsEnabled(bool value) async {
    await prefs.setBool(AppConstants.startWithWindowsKey, value);
  }
}
