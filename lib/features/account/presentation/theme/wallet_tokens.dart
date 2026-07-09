import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Wallet screen (Figma + `WalletScreen.tsx`).
abstract final class WalletTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const cardTop = AppDarkSurfaces.surface;
  static const cardBottom = AppDarkSurfaces.surfaceContainerLow;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const accent = AppBrand.primary;
  static const accentSoft = Color(0xFF4D7DFF);
  static const green = Color(0xFF22C55E);
  static const gold = Color(0xFFF59E0B);
}
