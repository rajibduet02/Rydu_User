import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Safety Center (Figma + `SafetyCenterScreen.tsx`).
abstract final class SafetyCenterTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const cardTop = AppDarkSurfaces.surface;
  static const cardBottom = AppDarkSurfaces.surfaceElevated;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const accent = AppBrand.primary;
  static const accentDeep = AppBrand.primary;
  static const accentSoft = Color(0xFF4D7DFF);
  static const green = Color(0xFF22C55E);
  static const sosRed = Color(0xFFEF4444);
  static const phoneOrange = Color(0xFFF59E0B);
  static const trustedGreen = Color(0xFF10B981);
  static const ridePurple = Color(0xFF8B5CF6);
}
