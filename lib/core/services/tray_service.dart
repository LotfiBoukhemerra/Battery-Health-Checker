import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

/// Service for managing the Windows system tray icon
/// and context menu.
class TrayService {
  final SystemTray _tray = SystemTray();
  bool _initialized = false;

  VoidCallback? onShowWindow;
  VoidCallback? onCheckBattery;
  VoidCallback? onExit;

  /// Initializes the system tray with icon and menu.
  /// Gracefully handles missing icons or platform issues.
  Future<void> init() async {
    if (_initialized) return;

    try {
      final iconPath = _getIconPath();
      await _tray.initSystemTray(
        title: 'Battery Checker',
        iconPath: iconPath,
        toolTip: 'Battery Checker',
      );

      final menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(label: 'Show', onClicked: (_) => _handleShow()),
        MenuItemLabel(
          label: 'Check Battery',
          onClicked: (_) => onCheckBattery?.call(),
        ),
        MenuSeparator(),
        MenuItemLabel(label: 'Exit', onClicked: (_) => _handleExit()),
      ]);
      await _tray.setContextMenu(menu);

      _tray.registerSystemTrayEventHandler((event) {
        if (event == kSystemTrayEventClick ||
            event == kSystemTrayEventDoubleClick) {
          _handleShow();
        } else if (event == kSystemTrayEventRightClick) {
          _tray.popUpContextMenu();
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint('System tray init failed: $e');
      // Tray is not critical — app works without it.
    }
  }

  /// Updates the tray tooltip with battery info.
  Future<void> updateTooltip(String tooltip) async {
    if (!_initialized) return;
    try {
      await _tray.setToolTip(tooltip);
    } catch (_) {}
  }

  void _handleShow() {
    windowManager.show();
    windowManager.focus();
    onShowWindow?.call();
  }

  void _handleExit() {
    onExit?.call();
    exit(0);
  }

  /// Gets the icon path for the tray.
  ///
  /// `system_tray` on Windows requires a valid `.ico`
  /// file. We look for the runner's `app_icon.ico`
  /// first, then fall back to a bundled PNG.
  String _getIconPath() {
    final exeDir = File(Platform.resolvedExecutable).parent;

    // 1. Bundled .ico in flutter_assets (works in
    //    both debug and Release builds).
    final assetsIcoPath =
        '${exeDir.path}\\data\\flutter_assets\\'
        'assets\\images\\app_icon.ico';
    if (File(assetsIcoPath).existsSync()) {
      return assetsIcoPath;
    }

    // 2. .ico adjacent to the exe (debug fallback).
    final adjacentIcoPath = '${exeDir.path}\\app_icon.ico';
    if (File(adjacentIcoPath).existsSync()) {
      return adjacentIcoPath;
    }

    // Fallback — empty string will cause system_tray
    // to use a default icon (or fail gracefully).
    return '';
  }

  /// Cleans up tray resources.
  Future<void> dispose() async {
    if (!_initialized) return;
    try {
      await _tray.destroy();
    } catch (_) {}
  }
}
