/// Abstract repository for user settings/preferences.
///
/// Defines the contract for persisting alert thresholds,
/// notification toggles, and system behaviour settings.
abstract class SettingsRepository {
  // ── Alert thresholds ────────────────────────────────

  /// Returns the low battery alert threshold (5-45 %).
  Future<int> getLowThreshold();

  /// Returns the high battery alert threshold (50-100 %).
  Future<int> getHighThreshold();

  /// Whether the low battery alert is enabled.
  Future<bool> isLowAlertEnabled();

  /// Whether the high battery alert is enabled.
  Future<bool> isHighAlertEnabled();

  /// Persists the low battery alert threshold.
  Future<void> setLowThreshold(int value);

  /// Persists the high battery alert threshold.
  Future<void> setHighThreshold(int value);

  /// Enables or disables the low battery alert.
  Future<void> setLowAlertEnabled(bool value);

  /// Enables or disables the high battery alert.
  Future<void> setHighAlertEnabled(bool value);

  // ── System behaviour ────────────────────────────────

  /// Whether the app minimizes to the system tray
  /// instead of closing when the window is dismissed.
  Future<bool> isMinimizeToTrayEnabled();

  /// Enables or disables minimize-to-tray behaviour.
  Future<void> setMinimizeToTrayEnabled(bool value);

  /// Whether the app starts automatically with Windows.
  Future<bool> isStartWithWindowsEnabled();

  /// Enables or disables auto-start with Windows.
  Future<void> setStartWithWindowsEnabled(bool value);
}
