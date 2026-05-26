import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../domain/entities/battery_info.dart';
import '../../providers/battery_provider.dart';
import '../../widgets/battery_info_row.dart';
import '../../widgets/wave_battery_indicator.dart';

/// Main battery information screen for Windows.
///
/// Displays the wave battery indicator, health status,
/// battery details, and current charge information.
class BatteryScreen extends StatelessWidget {
  final BatteryProvider batteryProvider;

  /// Whether the wave animation should be active.
  final bool isActive;

  const BatteryScreen({
    super.key,
    required this.batteryProvider,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: batteryProvider,
      builder: (context, _) {
        if (batteryProvider.isLoading && !batteryProvider.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (batteryProvider.errorMessage != null && !batteryProvider.hasData) {
          return AppErrorWidget(
            message: batteryProvider.errorMessage,
            onRetry: () => batteryProvider.refresh(),
          );
        }

        final info = batteryProvider.batteryInfo;
        if (info == null) {
          return AppErrorWidget(onRetry: () => batteryProvider.refresh());
        }

        return _BatteryContent(
          info: info,
          onRefresh: () => batteryProvider.refresh(),
          isRefreshing: batteryProvider.isLoading,
          isActive: isActive,
        );
      },
    );
  }
}

class _BatteryContent extends StatelessWidget {
  final BatteryInfo info;
  final VoidCallback onRefresh;
  final bool isRefreshing;
  final bool isActive;

  const _BatteryContent({
    required this.info,
    required this.onRefresh,
    required this.isRefreshing,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column (Battery Status and Wave)
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.tr('battery_power'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  WaveBatteryIndicator(
                    level: info.level,
                    isCharging: info.isCharging,
                    size: 180,
                    isActive: isActive,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        info.isCharging
                            ? HugeIcons.strokeRoundedBatteryCharging01
                            : HugeIcons.strokeRoundedBatteryLow,
                        size: 16,
                        color: info.isCharging
                            ? AppColors.primary
                            : (isDark ? Colors.white54 : Colors.black45),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        info.isCharging
                            ? AppStrings.tr('charging')
                            : AppStrings.tr('discharging'),
                        style: TextStyle(
                          fontSize: 14,
                          color: info.isCharging
                              ? AppColors.primary
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 220,
                    child: OutlinedButton.icon(
                      onPressed: isRefreshing ? null : onRefresh,
                      icon: isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(
                              HugeIcons.strokeRoundedRefresh,
                              size: 18,
                            ),
                      label: Text(AppStrings.tr('refresh')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),

            // Right Column (Details and Health)
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  // Battery Health section
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          title: AppStrings.tr('battery_health'),
                          icon: HugeIcons.strokeRoundedHealth,
                        ),
                        const SizedBox(height: 8),

                        // Health percentage badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: info.healthColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: info.healthColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${info.healthPercent.round()}%',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: info.healthColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Health status text
                        Center(
                          child: Text(
                            AppStrings.tr(info.healthStatus),
                            style: TextStyle(
                              fontSize: 14,
                              color: info.healthColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        BatteryInfoRow(
                          icon: HugeIcons.strokeRoundedBatteryFull,
                          iconColor: AppColors.primary,
                          label: AppStrings.tr('design_capacity'),
                          value: BatteryInfo.formatCapacity(
                            info.designCapacityMwh,
                          ),
                        ),
                        BatteryInfoRow(
                          icon: HugeIcons.strokeRoundedBatteryCharging01,
                          iconColor: info.healthColor,
                          label: AppStrings.tr('full_charge_capacity'),
                          value: BatteryInfo.formatCapacity(
                            info.fullChargeCapacityMwh,
                          ),
                        ),
                        if (info.cycleCount != '-')
                          BatteryInfoRow(
                            icon: HugeIcons.strokeRoundedRefresh,
                            iconColor: AppColors.iconCyan,
                            label: AppStrings.tr('cycle_count'),
                            value: info.cycleCount,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Battery Details section
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(
                          title: AppStrings.tr('battery_details'),
                          icon: HugeIcons.strokeRoundedInformationCircle,
                        ),
                        const SizedBox(height: 4),
                        BatteryInfoRow(
                          icon: HugeIcons.strokeRoundedTag01,
                          iconColor: AppColors.iconGreen,
                          label: AppStrings.tr('battery_name'),
                          value: info.name,
                        ),
                        BatteryInfoRow(
                          icon: HugeIcons.strokeRoundedFactory,
                          iconColor: AppColors.iconCyan,
                          label: AppStrings.tr('manufacturer'),
                          value: info.manufacturer,
                        ),
                        BatteryInfoRow(
                          icon: HugeIcons.strokeRoundedBarCode01,
                          iconColor: AppColors.iconAmber,
                          label: AppStrings.tr('serial_number'),
                          value: info.serialNumber,
                        ),
                        BatteryInfoRow(
                          icon: HugeIcons.strokeRoundedTestTube,
                          iconColor: AppColors.iconPurple,
                          label: AppStrings.tr('chemistry'),
                          value: info.chemistry,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedInformationCircle,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.tr('battery_report_info'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header with icon and title.
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }
}
