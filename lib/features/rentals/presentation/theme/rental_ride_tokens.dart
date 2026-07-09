import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Rental ride selection — matches React / screenshot tokens.
abstract final class RentalRideTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const cardSelected = AppDarkSurfaces.surface;
  static const cardUnselected = AppDarkSurfaces.surfaceContainerLow;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const borderSelected = AppBrand.primary;
  static const white = Color(0xFFFFFFFF);
  static const muted = AppDarkText.secondary;
  static const mutedLabel = Color(0xFF94A3B8);
  static const bolt = Color(0xFFFF6B2C);
  static const cashGreen = Color(0xFF22C55E);
  static const black = AppDarkText.primary;

  static const backSize = 40.0;
  static const cardRadius = 16.0;
  static const ctaRadius = 20.0;
  static const promoRadius = 16.0;
}
