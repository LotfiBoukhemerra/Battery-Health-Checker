import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants/app_constants.dart';
import 'core/l10n/app_strings.dart';
import 'core/services/tray_service.dart';
import 'core/services/update_service.dart';
import 'core/services/windows_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'data/datasources/windows_battery_data_source.dart';
import 'data/repositories/battery_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/alerts_provider.dart';
import 'presentation/providers/battery_provider.dart';
import 'presentation/providers/update_provider.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if launched with --minimized (e.g. from
  // Windows startup) to start hidden in system tray.
  final startMinimized = args.contains('--minimized');

  // Initialize window manager
  await windowManager.ensureInitialized();

  // Compute dynamic window height: 70% of logical
  // screen height, clamped to [500, 680]. This keeps
  // the window proportional on every display — from
  // 13" laptops with 150% scaling to large monitors.
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final logicalScreenHeight = view.physicalSize.height / view.devicePixelRatio;
  final dynamicHeight =
      (logicalScreenHeight * AppConstants.windowHeightScreenRatio).clamp(
        AppConstants.minWindowHeight,
        AppConstants.maxWindowHeight,
      );

  final windowOptions = WindowOptions(
    size: Size(AppConstants.defaultWindowWidth, dynamicHeight),
    minimumSize: Size(
      AppConstants.minWindowWidth,
      AppConstants.minWindowHeight,
    ),
    center: true,
    title: AppConstants.appName,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setResizable(true);
    await windowManager.setMaximizable(false);
    if (!startMinimized) {
      await windowManager.show();
      await windowManager.focus();
    }
  });

  // Initialize SharedPreferences (single instance reused)
  final prefs = await SharedPreferences.getInstance();

  // Initialize localization with the same prefs instance
  await AppStrings.init(prefs);

  // Create services
  final notificationService = WindowsNotificationService();
  await notificationService.init();
  final trayService = TrayService();
  await trayService.init();

  // Create data layer
  final dataSource = WindowsBatteryDataSource();
  final batteryRepository = BatteryRepositoryImpl(dataSource: dataSource);
  final settingsRepository = SettingsRepositoryImpl(prefs: prefs);

  // Create providers
  final themeProvider = ThemeProvider(prefs: prefs);
  final alertsProvider = AlertsProvider(settingsRepository: settingsRepository);

  // Load alert settings before BatteryProvider needs them.
  await alertsProvider.loadSettings();

  final batteryProvider = BatteryProvider(
    repository: batteryRepository,
    alertsProvider: alertsProvider,
    notificationService: notificationService,
  );

  // Set up tray callbacks
  trayService.onCheckBattery = () => batteryProvider.refresh();

  // Create update checker
  final updateService = UpdateService();
  final updateProvider = UpdateProvider(
    updateService: updateService,
    notificationService: notificationService,
  );

  runApp(
    BatteryCheckerApp(
      themeProvider: themeProvider,
      batteryProvider: batteryProvider,
      alertsProvider: alertsProvider,
      trayService: trayService,
      updateProvider: updateProvider,
      startMinimized: startMinimized,
    ),
  );
}

/// Root widget for the Battery Checker Windows app.
class BatteryCheckerApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  final BatteryProvider batteryProvider;
  final AlertsProvider alertsProvider;
  final TrayService trayService;
  final UpdateProvider updateProvider;
  final bool startMinimized;

  const BatteryCheckerApp({
    super.key,
    required this.themeProvider,
    required this.batteryProvider,
    required this.alertsProvider,
    required this.trayService,
    required this.updateProvider,
    required this.startMinimized,
  });

  @override
  State<BatteryCheckerApp> createState() => _BatteryCheckerAppState();
}

class _BatteryCheckerAppState extends State<BatteryCheckerApp>
    with WindowListener {
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    _isVisible = !widget.startMinimized;

    windowManager.addListener(this);
    windowManager.setPreventClose(true);

    // Listen to tray show events to restore visibility
    widget.trayService.onShowWindow = () {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    };

    // Start periodic refresh and initial fetch
    widget.batteryProvider.startPeriodicRefresh();

    // Silent update check on startup
    widget.updateProvider.checkSilently();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    widget.batteryProvider.dispose();
    widget.trayService.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    final minimizeToTray = widget.alertsProvider.minimizeToTrayEnabled;

    if (minimizeToTray) {
      // Minimize to system tray — the user can restore
      // via tray icon or exit via the tray "Exit" menu.
      if (mounted) {
        setState(() => _isVisible = false);
      }
      await windowManager.hide();
    } else {
      // Close the app completely.
      exit(0);
    }
  }

  @override
  void onWindowMinimize() {
    if (mounted) {
      setState(() => _isVisible = false);
    }
  }

  @override
  void onWindowRestore() {
    if (mounted) {
      setState(() => _isVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeProvider,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: widget.themeProvider.themeMode,
          home: TickerMode(
            enabled: _isVisible,
            child: HomePage(
              themeProvider: widget.themeProvider,
              batteryProvider: widget.batteryProvider,
              alertsProvider: widget.alertsProvider,
              trayService: widget.trayService,
              updateProvider: widget.updateProvider,
            ),
          ),
        );
      },
    );
  }
}
