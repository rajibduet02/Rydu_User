import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Home screen (React `HomeScreen.tsx` + Figma reference).
abstract final class HomeScreenTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const surface = AppDarkSurfaces.surface;
  static const border = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const accent = AppBrand.primary;
  static const accentSoft = AppBrand.primaryLight;

  static const discountRed = Color(0xFFDC2626);
  static const promoGreenStart = Color(0xFF22C55E);
  static const promoGreenEnd = Color(0xFF16A34A);

  static const navActiveBg = AppBrand.primarySoft;
}
