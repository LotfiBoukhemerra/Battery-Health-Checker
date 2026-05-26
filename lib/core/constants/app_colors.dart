import 'package:flutter/material.dart';

/// Centralized color definitions for the entire app.
///
/// **All** UI colors must be referenced from this file so
/// the design system can be updated from a single source.
///
/// Primary brand color: `#2CCF6D` (vibrant green).
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────

  /// Primary brand green used across buttons, icons,
  /// indicators, and accent surfaces.
  static const Color primary = Color(0xFF2CCF6D);

  /// Lighter variant for secondary surfaces and
  /// color scheme secondary slot.
  static const Color primaryLight = Color(0xFF5EE89A);

  /// Darker variant for pressed states and contrast.
  static const Color primaryDark = Color(0xFF1FA855);

  // ── Battery indicator gradient ───────────────────────

  /// Start color for the wave battery gradient.
  static const Color gradientStart = Color(0xFF2CCF6D);

  /// End color for the wave battery gradient.
  static const Color gradientEnd = Color(0xFF0FA968);

  /// Main wave fill color.
  static const Color waveColor = Color(0xFF2CCF6D);

  /// Semi-transparent wave overlay.
  static const Color waveColorLight = Color(0x802CCF6D);

  // ── Battery level colors ─────────────────────────────

  /// High battery level (> 60 %).
  static const Color batteryHigh = Color(0xFF2CCF6D);

  /// Medium battery level (21-60 %).
  static const Color batteryMedium = Color(0xFFFFA726);

  /// Low battery level (≤ 20 %).
  static const Color batteryLow = Color(0xFFEF5350);

  /// Charging state indicator.
  static const Color batteryCharging = Color(0xFF42A5F5);

  // ── Health status colors ─────────────────────────────
  // Used by [BatteryInfo.healthColor] and [BatteryUtils]
  // to convey battery health at a glance.

  /// Excellent health (≥ 90 %).
  static const Color healthExcellent = Color(0xFF06C86F);

  /// Good health (70-89 %).
  static const Color healthGood = Color(0xFF3CD662);

  /// Moderate health (50-69 %).
  static const Color healthModerate = Color(0xFF0DAFD8);

  /// Needs attention (30-49 %).
  static const Color healthWarning = Color(0xFFFFB300);

  /// Replace soon (< 30 %).
  static const Color healthCritical = Color(0xFFFF5252);

  // ── Icon accent colors ───────────────────────────────
  // Semantic accent colors applied to setting/info icons
  // to visually distinguish different rows.

  /// Cyan accent for info-style icons (globe, cycle, etc).
  static const Color iconCyan = Color(0xFF0DAFD8);

  /// Amber accent for donate / serial number icons.
  static const Color iconAmber = Color(0xFFFFB300);

  /// Purple accent for legal / chemistry / startup icons.
  static const Color iconPurple = Color(0xFFAB47BC);

  /// Red accent for low-battery alert icon.
  static const Color iconRed = Color(0xFFFF5252);

  /// Green accent for battery-name icon.
  static const Color iconGreen = Color(0xFF3CD662);

  // ── Dark theme ───────────────────────────────────────

  /// Scaffold background for dark mode.
  static const Color darkBackground = Color(0xFF0D0D0D);

  /// Surface color for dark mode (navigation rail, etc).
  static const Color darkSurface = Color(0xFF1A1A1A);

  /// Card background for dark mode.
  static const Color darkCard = Color(0xFF242424);

  /// Divider color for dark mode.
  static const Color darkDivider = Color(0xFF2E2E2E);

  /// Primary text color for dark mode.
  static const Color darkText = Color(0xFFE8E8E8);

  /// Secondary/muted text color for dark mode.
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // ── Light theme ──────────────────────────────────────

  /// Scaffold background for light mode.
  static const Color lightBackground = Color(0xFFF5F7FA);

  /// Surface color for light mode.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Card background for light mode.
  static const Color lightCard = Color(0xFFFFFFFF);

  /// Divider color for light mode.
  static const Color lightDivider = Color(0xFFE0E0E0);

  /// Primary text color for light mode.
  static const Color lightText = Color(0xFF1A1A1A);

  /// Secondary/muted text color for light mode.
  static const Color lightTextSecondary = Color(0xFF757575);

  // ── Glass effect ─────────────────────────────────────

  /// Glass card fill color (dark mode).
  static const Color glassDark = Color(0x33FFFFFF);

  /// Glass card border color (dark mode).
  static const Color glassBorderDark = Color(0x22FFFFFF);

  /// Glass card fill color (light mode).
  static const Color glassLight = Color(0xBBFFFFFF);

  /// Glass card border color (light mode).
  static const Color glassBorderLight = Color(0x44000000);

  // ── Semantic status colors ───────────────────────────

  /// Informational blue.
  static const Color info = Color(0xFF42A5F5);

  /// Warning amber.
  static const Color warning = Color(0xFFFFA726);

  /// Error red.
  static const Color error = Color(0xFFEF5350);

  /// Success green.
  static const Color success = Color(0xFF2CCF6D);

  // ── Helpers ──────────────────────────────────────────

  /// Returns a color representing the current battery level.
  static Color getBatteryColor(int? level) {
    if (level == null) return Colors.grey;
    if (level > 60) return batteryHigh;
    if (level > 20) return batteryMedium;
    return batteryLow;
  }

  /// Returns a color representing the battery health
  /// percentage.
  static Color getHealthColor(double healthPercent) {
    if (healthPercent >= 90) return healthExcellent;
    if (healthPercent >= 70) return healthGood;
    if (healthPercent >= 50) return healthModerate;
    if (healthPercent >= 30) return healthWarning;
    return healthCritical;
  }
}
