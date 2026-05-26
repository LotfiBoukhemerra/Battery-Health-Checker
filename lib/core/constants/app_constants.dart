/// App-wide constants: keys and default values.
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Battery Checker';
  static const String appVersion = '1.0.0';
  static const String websiteUrl = 'https://batterychecker.org';
  static const String privacyUrl =
      'https://batterychecker.org/privacy-policy.html';
  static const String kofiUrl = 'https://ko-fi.com/lotfibkmr';
  static const String paypalUrl = 'https://www.paypal.me/LotfiBoukhemerra';

  // Refresh intervals
  static const Duration refreshInterval = Duration(seconds: 30);

  // SharedPreferences keys
  static const String themeKey = 'app_theme';
  static const String lowThresholdKey = 'low_threshold';
  static const String highThresholdKey = 'high_threshold';
  static const String lowAlertEnabledKey = 'low_alert_enabled';
  static const String highAlertEnabledKey = 'high_alert_enabled';
  static const String minimizeToTrayKey = 'minimize_to_tray';
  static const String startWithWindowsKey = 'start_with_windows';
  static const String localeKey = 'app_locale';

  // Default thresholds
  static const int defaultLowThreshold = 20;
  static const int defaultHighThreshold = 80;

  // Window constraints
  static const double minWindowWidth = 800;
  static const double minWindowHeight = 600;
  static const double defaultWindowWidth = 800;
  static const double maxWindowHeight = 600;

  /// Fraction of screen height used for the default
  /// window height (0.7 = 70%).
  static const double windowHeightScreenRatio = 0.7;
}
