import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Utility functions for battery-related computations.
class BatteryUtils {
  BatteryUtils._();

  /// Returns a human-readable charging status string.
  static String getChargingStatusText(bool isCharging) {
    return isCharging ? 'Charging' : 'Not Charging';
  }

  /// Returns the color for a given health percentage.
  ///
  /// Delegates to [AppColors.getHealthColor] so that
  /// all health-related colors stay in one place.
  static Color getHealthColor(double healthPercent) =>
      AppColors.getHealthColor(healthPercent);

  /// Returns a human-readable health status text.
  static String getHealthStatusText(double healthPercent) {
    if (healthPercent >= 90) return 'Excellent';
    if (healthPercent >= 70) return 'Good';
    if (healthPercent >= 50) return 'Moderate';
    if (healthPercent >= 30) return 'Needs Attention';
    return 'Replace Soon';
  }
}
