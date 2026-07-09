import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Safety Resources (screenshot reference).
abstract final class SafetyResourcesTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const card = AppDarkSurfaces.surface;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const label = AppDarkText.muted;
  static const white = Color(0xFFFFFFFF);
  static const accent = Color(0xFF4D7DFF);
  static const accentSolid = AppBrand.primary;
  static const emergencyRed = Color(0xFFEF4444);
  static const emergencyIconBg = Color(0xFFDC2626);
  static const checkGreen = Color(0xFF22C55E);
  static const buttonTextDark = Color(0xFF0B1220);
}
