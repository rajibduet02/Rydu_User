import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Rental time selection — screenshot / React tokens.
abstract final class RentalTimeTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const panelFill = AppDarkSurfaces.surface;
  static const border = AppDarkSurfaces.border;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFF94A3B8);
  static const subtitleBlue = AppDarkText.secondary;
  static const sliderActive = AppBrand.primary;
  static const sliderActiveEnd = Color(0xFF4D7DFF);
  static const sliderTrack = AppDarkSurfaces.border;
  static const thumb = Color(0xFFFFFFFF);
  static const black = AppDarkText.primary;

  static const backSize = 40.0;
  static const stepButtonSize = 56.0;
  static const radiusPill = 999.0;
  static const ctaRadius = 20.0;
}
