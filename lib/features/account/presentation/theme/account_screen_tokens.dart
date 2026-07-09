import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Account / profile dashboard (Figma + React `AccountScreen.tsx`).
abstract final class AccountScreenTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const card = AppDarkSurfaces.surface;
  static const cardDeep = AppDarkSurfaces.surfaceContainerLow;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const accent = AppBrand.primary;
  static const accentSoft = AppBrand.primaryLight;
  static const gold = Color(0xFFF59E0B);
  static const green = Color(0xFF22C55E);
  static const walletGreen = Color(0xFF22C55E);
  static const newOrange = Color(0xFFFF6B2C);
  static const logoutRed = Color(0xFFEF4444);
  static const navActiveBg = AppBrand.primarySoft;
}
