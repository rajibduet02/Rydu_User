import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Settings (Figma + `SettingsScreen.tsx`).
abstract final class SettingsScreenTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const cardTop = AppDarkSurfaces.surface;
  static const cardBottom = AppDarkSurfaces.surfaceContainerLow;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const accent = AppBrand.primary;
}
