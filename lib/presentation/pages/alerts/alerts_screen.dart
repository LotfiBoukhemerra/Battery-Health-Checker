import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/widgets/glass_card.dart';
import '../../providers/alerts_provider.dart';
import '../../widgets/settings_tile.dart';

/// Alerts configuration screen with threshold
/// sliders and toggle switches for battery alerts.
class AlertsScreen extends StatelessWidget {
  final AlertsProvider alertsProvider;

  const AlertsScreen({super.key, required this.alertsProvider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: alertsProvider,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  AppStrings.tr('smart_alerts'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 24),

                // Low battery alert
                GlassCard(
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedBatteryLow,
                        iconColor: AppColors.iconRed,
                        title: AppStrings.tr('low_battery_alert'),
                        subtitle: AppStrings.trWithParam(
                          'low_battery_desc',
                          'value',
                          alertsProvider.lowThreshold.toString(),
                        ),
                        trailing: Switch(
                          value: alertsProvider.lowAlertEnabled,
                          onChanged: (v) =>
                              alertsProvider.setLowAlertEnabled(v),
                        ),
                      ),
                      if (alertsProvider.lowAlertEnabled)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '5%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: alertsProvider.lowThreshold.toDouble(),
                                  min: 5,
                                  max: 45,
                                  divisions: 8,
                                  onChanged: (v) =>
                                      alertsProvider.setLowThreshold(v.round()),
                                ),
                              ),
                              Text(
                                '45%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // High battery alert
                GlassCard(
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedBatteryFull,
                        iconColor: AppColors.primary,
                        title: AppStrings.tr('full_charge_alert'),
                        subtitle: AppStrings.trWithParam(
                          'full_charge_desc',
                          'value',
                          alertsProvider.highThreshold.toString(),
                        ),
                        trailing: Switch(
                          value: alertsProvider.highAlertEnabled,
                          onChanged: (v) =>
                              alertsProvider.setHighAlertEnabled(v),
                        ),
                      ),
                      if (alertsProvider.highAlertEnabled)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '50%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: alertsProvider.highThreshold
                                      .toDouble(),
                                  min: 50,
                                  max: 100,
                                  divisions: 10,
                                  onChanged: (v) => alertsProvider
                                      .setHighThreshold(v.round()),
                                ),
                              ),
                              Text(
                                '100%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // System tray options
                GlassCard(
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedComputerDesk01,
                        iconColor: AppColors.iconCyan,
                        title: AppStrings.tr('minimize_to_tray'),
                        subtitle: AppStrings.tr('minimize_to_tray_desc'),
                        trailing: Switch(
                          value: alertsProvider.minimizeToTrayEnabled,
                          onChanged: (v) =>
                              alertsProvider.setMinimizeToTrayEnabled(v),
                        ),
                      ),
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedStartUp01,
                        iconColor: AppColors.iconPurple,
                        title: AppStrings.tr('start_with_windows'),
                        subtitle: AppStrings.tr('start_with_windows_desc'),
                        trailing: Switch(
                          value: alertsProvider.startWithWindowsEnabled,
                          onChanged: (v) =>
                              alertsProvider.setStartWithWindowsEnabled(v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedInformationCircle,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.tr('alert_info'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
