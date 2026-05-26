import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/services/update_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/theme_provider.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/update_provider.dart';
import '../../widgets/settings_tile.dart';

/// Settings screen — theme, language, support links.
class SettingsScreen extends StatelessWidget {
  final ThemeProvider themeProvider;
  final AlertsProvider alertsProvider;
  final UpdateProvider updateProvider;

  const SettingsScreen({
    super.key,
    required this.themeProvider,
    required this.alertsProvider,
    required this.updateProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
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
                  AppStrings.tr('settings'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 24),

                // Appearance section
                _SectionLabel(
                  title: AppStrings.tr('appearance'),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  child: Column(
                    children: [
                      // Theme selector
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedPaintBrush04,
                        iconColor: AppColors.primary,
                        title: AppStrings.tr('appearance'),
                        subtitle: AppStrings.tr(themeProvider.themeDisplayKey),
                        onTap: () => _showThemeDialog(context),
                      ),

                      // Language selector
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedGlobe,
                        iconColor: AppColors.iconCyan,
                        title: AppStrings.tr('change_language'),
                        subtitle:
                            AppStrings.localeNames[AppStrings
                                .currentLocale
                                .languageCode] ??
                            'English',
                        onTap: () => _showLanguageDialog(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Support section
                _SectionLabel(title: AppStrings.tr('support'), isDark: isDark),
                const SizedBox(height: 8),
                GlassCard(
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedGlobe,
                        iconColor: AppColors.iconCyan,
                        title: AppStrings.tr('visit_website'),
                        subtitle: AppConstants.websiteUrl,
                        onTap: () => _launchUrl(AppConstants.websiteUrl),
                      ),
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedPaypal,
                        iconColor: AppColors.info,
                        title: 'Paypal',
                        subtitle: 'paypal.me/LotfiBoukhemerra',
                        onTap: () => _launchUrl(AppConstants.paypalUrl),
                      ),
                      SettingsTile(
                        icon: HugeIcons.strokeRoundedCoffee02,
                        iconColor: AppColors.iconAmber,
                        title: 'Ko-fi',
                        subtitle: 'ko-fi.com/lotfibkmr',
                        onTap: () => _launchUrl(AppConstants.kofiUrl),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Legal section
                _SectionLabel(title: AppStrings.tr('legal'), isDark: isDark),
                const SizedBox(height: 8),
                GlassCard(
                  child: SettingsTile(
                    icon: HugeIcons.strokeRoundedSecurityCheck,
                    iconColor: AppColors.iconPurple,
                    title: AppStrings.tr('privacy_policy'),
                    onTap: () => _launchUrl(AppConstants.privacyUrl),
                  ),
                ),
                const SizedBox(height: 16),

                // Updates section
                _SectionLabel(
                  title: AppStrings.tr('check_for_updates'),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  child: SettingsTile(
                    icon: HugeIcons.strokeRoundedDownload04,
                    iconColor: AppColors.info,
                    title: AppStrings.tr('check_for_updates'),
                    subtitle: AppStrings.trWithParam(
                      'version',
                      'version',
                      AppConstants.appVersion,
                    ),
                    onTap: () => _checkForUpdates(context),
                  ),
                ),
                const SizedBox(height: 24),

                // About footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppStrings.trWithParam(
                          'version',
                          'version',
                          AppConstants.appVersion,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.tr('developer_name'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
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

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.tr('appearance')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final label = switch (mode) {
              ThemeMode.light => 'theme_light',
              ThemeMode.dark => 'theme_dark',
              ThemeMode.system => 'theme_system',
            };
            final isSelected = themeProvider.themeMode == mode;
            return ListTile(
              title: Text(AppStrings.tr(label)),
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : null,
              ),
              onTap: () {
                themeProvider.setThemeMode(mode);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.tr('change_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppStrings.supportedLocales.map((locale) {
            final isSelected =
                AppStrings.currentLocale.languageCode == locale.languageCode;
            return ListTile(
              title: Text(
                AppStrings.localeNames[locale.languageCode] ??
                    locale.languageCode,
              ),
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : null,
              ),
              onTap: () async {
                await AppStrings.setLocale(locale);
                if (ctx.mounted) Navigator.pop(ctx);
                // Rebuild the whole app to apply new
                // locale. We notify via themeProvider
                // as a simple trigger.
                themeProvider.setThemeMode(themeProvider.themeMode);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _checkForUpdates(BuildContext context) {
    updateProvider.checkManually();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ListenableBuilder(
        listenable: updateProvider,
        builder: (context, _) {
          return _UpdateDialog(
            state: updateProvider.state,
            updateInfo: updateProvider.updateInfo,
            onClose: () => Navigator.pop(ctx),
            onDownload: () async {
              if (updateProvider.updateInfo != null) {
                await _launchUrl(updateProvider.updateInfo!.releaseUrl);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionLabel({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

/// Dialog shown during and after a manual update check.
class _UpdateDialog extends StatelessWidget {
  final UpdateCheckState state;
  final UpdateInfo? updateInfo;
  final VoidCallback onClose;
  final VoidCallback onDownload;

  const _UpdateDialog({
    required this.state,
    required this.updateInfo,
    required this.onClose,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: _buildContent(context),
      ),
      actions: _buildActions(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (state) {
      case UpdateCheckState.checking:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(AppStrings.tr('update_checking')),
            ],
          ),
        );

      case UpdateCheckState.updateAvailable:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                HugeIcons.strokeRoundedDownload04,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr('update_available'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.trWithParam(
                'update_new_version',
                'version',
                updateInfo?.latestVersion ?? '',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        );

      case UpdateCheckState.upToDate:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                HugeIcons.strokeRoundedCheckmarkCircle01,
                color: AppColors.success,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr('update_up_to_date'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tr('update_up_to_date_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        );

      case UpdateCheckState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                HugeIcons.strokeRoundedAlertCircle,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr('update_error'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tr('update_error_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        );

      case UpdateCheckState.idle:
        return const SizedBox.shrink();
    }
  }

  List<Widget>? _buildActions(BuildContext context) {
    switch (state) {
      case UpdateCheckState.checking:
        return null;

      case UpdateCheckState.updateAvailable:
        return [
          TextButton(
            onPressed: onClose,
            child: Text(
              AppStrings.tr('tray_exit'),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: onDownload,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(AppStrings.tr('update_download')),
          ),
        ];

      default:
        return [TextButton(onPressed: onClose, child: const Text('OK'))];
    }
  }
}
