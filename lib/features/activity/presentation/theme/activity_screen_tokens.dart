import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Activity hub + filter sheet (Figma + React `ActivityScreen.tsx`).
abstract final class ActivityScreenTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const sheet = AppDarkSurfaces.surface;
  static const chipUnselectedBg = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const handle = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const onLight = AppDarkSurfaces.scaffold;
  static const accent = AppBrand.primary;
  static const navActiveBg = AppBrand.primarySoft;
}
