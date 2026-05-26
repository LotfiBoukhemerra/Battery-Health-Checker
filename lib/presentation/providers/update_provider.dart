import 'package:flutter/foundation.dart';

import '../../core/services/update_service.dart';
import '../../core/services/windows_notification_service.dart';

/// Possible states during an update check.
enum UpdateCheckState {
  /// No check has been performed yet.
  idle,

  /// A check is currently in progress.
  checking,

  /// A newer version is available.
  updateAvailable,

  /// The app is already on the latest version.
  upToDate,

  /// The check failed (e.g. no network).
  error,
}

/// Provider that manages update-check state and exposes
/// the latest [UpdateInfo] to the UI layer.
///
/// Supports both automatic (silent) checks that send
/// a Windows notification, and manual checks triggered
/// from the Settings screen.
class UpdateProvider extends ChangeNotifier {
  final UpdateService _updateService;
  final WindowsNotificationService _notificationService;

  UpdateCheckState _state = UpdateCheckState.idle;
  UpdateInfo? _updateInfo;

  UpdateProvider({
    required UpdateService updateService,
    required WindowsNotificationService notificationService,
  }) : _updateService = updateService,
       _notificationService = notificationService;

  /// Current state of the update check.
  UpdateCheckState get state => _state;

  /// Details about the latest release, available after
  /// a successful check.
  UpdateInfo? get updateInfo => _updateInfo;

  /// Whether a newer version is available.
  bool get hasUpdate => _state == UpdateCheckState.updateAvailable;

  /// Performs a silent background check on app startup.
  ///
  /// If a new version is found, fires a Windows toast
  /// notification and updates the state so the in-app
  /// banner can appear.
  Future<void> checkSilently() async {
    final info = await _updateService.checkForUpdate();
    if (info == null) return;

    if (info.isUpdateAvailable) {
      _updateInfo = info;
      _state = UpdateCheckState.updateAvailable;
      notifyListeners();

      await _notificationService.showUpdateNotification(
        version: info.latestVersion,
      );
    }
  }

  /// Performs a manual check triggered by the user.
  ///
  /// Updates the state to [checking], then to either
  /// [updateAvailable], [upToDate], or [error].
  Future<void> checkManually() async {
    _state = UpdateCheckState.checking;
    notifyListeners();

    final info = await _updateService.checkForUpdate();

    if (info == null) {
      _state = UpdateCheckState.error;
    } else if (info.isUpdateAvailable) {
      _updateInfo = info;
      _state = UpdateCheckState.updateAvailable;
    } else {
      _updateInfo = info;
      _state = UpdateCheckState.upToDate;
    }
    notifyListeners();
  }

  /// Dismisses the update banner without taking action.
  void dismiss() {
    _state = UpdateCheckState.idle;
    notifyListeners();
  }
}
