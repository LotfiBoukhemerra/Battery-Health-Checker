import 'package:flutter/foundation.dart';

import '../../core/services/startup_service.dart';
import '../../domain/repositories/settings_repository.dart';

/// ChangeNotifier managing alert settings.
///
/// Persists all changes to SharedPreferences via the
/// settings repository.
class AlertsProvider extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  int _lowThreshold = 20;
  int _highThreshold = 80;
  bool _lowAlertEnabled = true;
  bool _highAlertEnabled = true;
  bool _minimizeToTrayEnabled = false;
  bool _startWithWindowsEnabled = false;
  bool _isLoading = true;

  AlertsProvider({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository;

  int get lowThreshold => _lowThreshold;
  int get highThreshold => _highThreshold;
  bool get lowAlertEnabled => _lowAlertEnabled;
  bool get highAlertEnabled => _highAlertEnabled;
  bool get minimizeToTrayEnabled => _minimizeToTrayEnabled;
  bool get startWithWindowsEnabled => _startWithWindowsEnabled;
  bool get isLoading => _isLoading;

  /// Loads all alert settings from storage.
  Future<void> loadSettings() async {
    _lowThreshold = await _settingsRepository.getLowThreshold();
    _highThreshold = await _settingsRepository.getHighThreshold();
    _lowAlertEnabled = await _settingsRepository.isLowAlertEnabled();
    _highAlertEnabled = await _settingsRepository.isHighAlertEnabled();
    _minimizeToTrayEnabled = await _settingsRepository
        .isMinimizeToTrayEnabled();
    _startWithWindowsEnabled = await _settingsRepository
        .isStartWithWindowsEnabled();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLowThreshold(int value) async {
    final clamped = value.clamp(5, 45);
    _lowThreshold = clamped;
    notifyListeners();
    await _settingsRepository.setLowThreshold(clamped);
  }

  Future<void> setHighThreshold(int value) async {
    final clamped = value.clamp(50, 100);
    _highThreshold = clamped;
    notifyListeners();
    await _settingsRepository.setHighThreshold(clamped);
  }

  Future<void> setLowAlertEnabled(bool value) async {
    _lowAlertEnabled = value;
    notifyListeners();
    await _settingsRepository.setLowAlertEnabled(value);
  }

  Future<void> setHighAlertEnabled(bool value) async {
    _highAlertEnabled = value;
    notifyListeners();
    await _settingsRepository.setHighAlertEnabled(value);
  }

  Future<void> setMinimizeToTrayEnabled(bool value) async {
    _minimizeToTrayEnabled = value;
    notifyListeners();
    await _settingsRepository.setMinimizeToTrayEnabled(value);
  }

  Future<void> setStartWithWindowsEnabled(bool value) async {
    _startWithWindowsEnabled = value;
    notifyListeners();
    await _settingsRepository.setStartWithWindowsEnabled(value);

    // Actually register/unregister from Windows startup
    if (value) {
      await StartupService.enableStartup();
    } else {
      await StartupService.disableStartup();
    }
  }
}
