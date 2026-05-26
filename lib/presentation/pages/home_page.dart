import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/services/tray_service.dart';
import '../../core/theme/theme_provider.dart';
import '../providers/alerts_provider.dart';
import '../providers/battery_provider.dart';
import '../providers/update_provider.dart';
import '../widgets/donate_menu.dart';
import '../widgets/update_banner.dart';
import 'alerts/alerts_screen.dart';
import 'battery/battery_screen.dart';
import 'settings/settings_screen.dart';

/// Main app page with bottom navigation for
/// Battery, Alerts, and Settings tabs.
///
/// When no battery is detected, the navigation and
/// donate button are hidden and a full-screen message
/// is displayed instead.
class HomePage extends StatefulWidget {
  final ThemeProvider themeProvider;
  final BatteryProvider batteryProvider;
  final AlertsProvider alertsProvider;
  final TrayService trayService;
  final UpdateProvider updateProvider;

  const HomePage({
    super.key,
    required this.themeProvider,
    required this.batteryProvider,
    required this.alertsProvider,
    required this.trayService,
    required this.updateProvider,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isExtended = false;

  /// Cached screens — rebuilt only when the widget
  /// config changes, not on every build() call.
  late final AlertsScreen _alertsScreen = AlertsScreen(
    alertsProvider: widget.alertsProvider,
  );
  late final SettingsScreen _settingsScreen = SettingsScreen(
    themeProvider: widget.themeProvider,
    alertsProvider: widget.alertsProvider,
    updateProvider: widget.updateProvider,
  );

  /// Returns the active screen for the current tab.
  /// Only [BatteryScreen] needs to be rebuilt per-tab
  /// because of the [isActive] flag.
  Widget _screenForIndex(int index) {
    return switch (index) {
      0 => BatteryScreen(
        batteryProvider: widget.batteryProvider,
        isActive: true,
      ),
      1 => _alertsScreen,
      2 => _settingsScreen,
      _ => _alertsScreen,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.batteryProvider,
      builder: (context, _) {
        // When no battery is detected, show a
        // dedicated full-screen view without any
        // navigation or donate button.
        if (widget.batteryProvider.isNoBattery) {
          return _NoBatteryFullScreen(batteryProvider: widget.batteryProvider);
        }

        // When a virtual machine battery is detected,
        // show a dedicated full-screen message.
        if (widget.batteryProvider.isVirtualBattery) {
          return _VirtualBatteryFullScreen(
            batteryProvider: widget.batteryProvider,
          );
        }

        return _buildNormalLayout(context);
      },
    );
  }

  Widget _buildNormalLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: _isExtended,
            minExtendedWidth: 160,
            leading: IconButton(
              icon: const Icon(HugeIcons.strokeRoundedMenu01),
              onPressed: () {
                setState(() {
                  _isExtended = !_isExtended;
                });
              },
            ),
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            labelType: NavigationRailLabelType.none,
            backgroundColor: isDark
                ? AppColors.darkSurface
                : AppColors.lightSurface,
            indicatorColor: AppColors.primary.withValues(alpha: 0.15),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(HugeIcons.strokeRoundedBatteryFull),
                selectedIcon: Icon(
                  HugeIcons.strokeRoundedBatteryFull,
                  color: AppColors.primary,
                ),
                label: Text(AppStrings.tr('battery')),
              ),
              NavigationRailDestination(
                icon: const Icon(HugeIcons.strokeRoundedNotification03),
                selectedIcon: Icon(
                  HugeIcons.strokeRoundedNotification03,
                  color: AppColors.primary,
                ),
                label: Text(AppStrings.tr('alerts')),
              ),
              NavigationRailDestination(
                icon: const Icon(HugeIcons.strokeRoundedSettings02),
                selectedIcon: Icon(
                  HugeIcons.strokeRoundedSettings02,
                  color: AppColors.primary,
                ),
                label: Text(AppStrings.tr('settings')),
              ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: DonateMenu(
                  isExtended: _isExtended,
                  options: const [
                    DonateOption(
                      label: 'PayPal',
                      icon: HugeIcons.strokeRoundedPaypal,
                      color: Color(0xFF0070BA),
                      url: AppConstants.paypalUrl,
                    ),
                    DonateOption(
                      label: 'Ko-fi',
                      icon: HugeIcons.strokeRoundedCoffee02,
                      color: Color(0xFFFF5E5B),
                      url: AppConstants.kofiUrl,
                    ),
                  ],
                ),
              ),
            ),
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -200) {
                  // Swipe left
                  if (_currentIndex < 2) {
                    setState(() => _currentIndex++);
                  }
                } else if (details.primaryVelocity! > 200) {
                  // Swipe right
                  if (_currentIndex > 0) {
                    setState(() => _currentIndex--);
                  }
                }
              },
              child: Column(
                children: [
                  // Update banner
                  ListenableBuilder(
                    listenable: widget.updateProvider,
                    builder: (context, _) {
                      if (!widget.updateProvider.hasUpdate) {
                        return const SizedBox.shrink();
                      }
                      return UpdateBanner(
                        updateInfo: widget.updateProvider.updateInfo!,
                        onDismiss: widget.updateProvider.dismiss,
                      );
                    },
                  ),

                  // Main screen content
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: KeyedSubtree(
                        key: ValueKey(_currentIndex),
                        child: _screenForIndex(_currentIndex),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen widget shown when no battery is detected.
///
/// Hides navigation rail and donate button. Shows two
/// action buttons: "Check Again" and "Exit App".
class _NoBatteryFullScreen extends StatelessWidget {
  final BatteryProvider batteryProvider;

  const _NoBatteryFullScreen({required this.batteryProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Battery icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.iconAmber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedBatteryEmpty,
                  size: 48,
                  color: AppColors.iconAmber,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                AppStrings.tr('error_no_battery'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                AppStrings.tr('error_no_battery_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Check Again button
                  ElevatedButton.icon(
                    onPressed: () {
                      batteryProvider.startPeriodicRefresh();
                    },
                    icon: const Icon(HugeIcons.strokeRoundedRefresh, size: 18),
                    label: Text(AppStrings.tr('check_again')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Exit App button
                  OutlinedButton.icon(
                    onPressed: () => exit(0),
                    icon: const Icon(HugeIcons.strokeRoundedLogout03, size: 18),
                    label: Text(AppStrings.tr('exit_app')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen widget shown when a virtual machine
/// battery is detected (e.g. Hyper-V, VMware).
///
/// Uses the same layout as [_NoBatteryFullScreen] but
/// with a distinct icon, color, and message.
class _VirtualBatteryFullScreen extends StatelessWidget {
  final BatteryProvider batteryProvider;

  const _VirtualBatteryFullScreen({required this.batteryProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Virtual machine icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  HugeIcons.strokeRoundedVirtualRealityVr02,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                AppStrings.tr('error_virtual_battery'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                AppStrings.tr('error_virtual_battery_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white54
                      : Colors.black45,
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Check Again button
                  ElevatedButton.icon(
                    onPressed: () {
                      batteryProvider.startPeriodicRefresh();
                    },
                    icon: const Icon(
                      HugeIcons.strokeRoundedRefresh,
                      size: 18,
                    ),
                    label: Text(
                      AppStrings.tr('check_again'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Exit App button
                  OutlinedButton.icon(
                    onPressed: () => exit(0),
                    icon: const Icon(
                      HugeIcons.strokeRoundedLogout03,
                      size: 18,
                    ),
                    label: Text(
                      AppStrings.tr('exit_app'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.white70
                          : Colors.black54,
                      side: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : Colors.black26,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
