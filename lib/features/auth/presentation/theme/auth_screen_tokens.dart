import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Auth screens palette (aligned with [WelcomeTokens]).
abstract final class AuthScreenTokens {
  static const bg = AppDarkSurfaces.scaffold;
  static const card = AppDarkSurfaces.surface;
  static const field = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const accent = AppBrand.primary;
  static const accentEnd = AppBrand.primaryLight;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const link = AppBrand.primary;

  static const double radiusCard = 20;
  static const double radiusField = 12;
  static const double radiusButton = 20;
  static const double horizontalPadding = 24;
}
