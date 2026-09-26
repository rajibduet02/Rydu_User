import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Visual tokens aligned with React `RideBookingScreen` / design screenshot.
abstract final class RideBookingTokens {
  static const background = AppDarkSurfaces.scaffold;
  /// Light ride-selection bottom sheet (maps stay dark above).
  static const sheetBackground = Color(0xFFFFFFFF);
  static const sheetBorder = Color(0xFFE5E7EB);
  static const sheetTitle = Color(0xFF111827);
  static const sheetMuted = Color(0xFF6B7280);
  static const sheetCta = Color(0xFF111827);
  static const cardFill = AppDarkSurfaces.surface;
  static const border = AppDarkSurfaces.border;
  static const accent = AppBrand.primary;
  static const muted = AppDarkText.secondary;
  static const plusFill = AppDarkSurfaces.inputSurface;
  static const headerButtonFill = AppDarkSurfaces.surface;
  static const tileHover = AppDarkSurfaces.surface;
  static const titleWhite = Color(0xFFFFFFFF);
  static const cardRadius = 24.0;
  static const tileRadius = 16.0;
  static const headerButtonSize = 40.0;
  static const plusButtonSize = 40.0;
}
