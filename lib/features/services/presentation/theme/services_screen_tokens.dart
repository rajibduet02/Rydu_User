import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Services hub (Figma + React `ServicesScreen.tsx` reference).
abstract final class ServicesScreenTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const card = AppDarkSurfaces.surface;
  static const iconWell = AppDarkSurfaces.borderSubtle;
  static const border = AppDarkSurfaces.border;
  static const accent = AppBrand.primary;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const discountRed = Color(0xFFFF0000);
  static const navActiveBg = AppBrand.primarySoft;
}
