import 'package:local_notifier/local_notifier.dart';

/// Service for showing Windows toast notifications
/// for battery alerts.
class WindowsNotificationService {
  bool _initialized = false;
  bool lowAlertFired = false;
  bool highAlertFired = false;

  /// Initializes the local notification system.
  /// Must be called from main() right after window manager init.
  Future<void> init() async {
    if (_initialized) return;
    await localNotifier.setup(
      appName: 'Battery Checker',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
    _initialized = true;
  }

  /// Shows a low battery warning notification.
  Future<void> showLowBatteryAlert({required int level}) async {
    final notification = LocalNotification(
      title: 'Low Battery Warning',
      body:
          'Battery is at $level%. '
          'Please connect your charger.',
    );
    await notification.show();
  }

  /// Shows a full charge notification.
  Future<void> showHighBatteryAlert({required int level}) async {
    final notification = LocalNotification(
      title: 'Battery Fully Charged',
      body:
          'Battery is at $level%. '
          'You can disconnect your charger.',
    );
    await notification.show();
  }

  /// Shows a notification when a new app version is
  /// available for download.
  Future<void> showUpdateNotification({required String version}) async {
    final notification = LocalNotification(
      title: 'Update Available',
      body:
          'Battery Checker v$version is now available. '
          'Open the app to download.',
    );
    await notification.show();
  }
}
