import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Intercity hub — aligned with design / React `IntercityScreen`.
abstract final class IntercityTokens {
  /// Screenshot-leaning deep navy (React used `#060B14`; spec `#0a0e14`).
  static const background = AppDarkSurfaces.scaffold;
  static const cardFill = AppDarkSurfaces.surface;
  static const border = AppDarkSurfaces.border;
  static const accent = AppBrand.primary;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const headerButtonFill = AppDarkSurfaces.surface;

  static const offerGreen = Color(0xFF22C55E);
  static const offerBorder = Color(0x4D22C55E); // ~30% green
  static const offerGradientStart = Color(0x3322C55E);
  static const offerGradientEnd = Color(0x1A22C55E);

  static const searchButtonText = AppDarkText.primary;
  static const searchButtonFill = Color(0xFFFFFFFF);

  static const headerButtonSize = 40.0;
  static const radiusLg = 20.0;
  static const radiusMd = 16.0;
  static const radiusOffer = 16.0;
}
