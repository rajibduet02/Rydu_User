import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Reserve hub — screenshot + React `ReserveScreen` tokens.
abstract final class ReserveTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const iconWell = AppDarkSurfaces.surfaceElevated;
  static const accentBlue = AppBrand.primary;
  static const white = Color(0xFFFFFFFF);
  static const buttonText = AppDarkText.primary;
  static const buttonFill = Color(0xFFFFFFFF);
  static const backFill = Color(0x99000000);
  static const backBorder = Color(0x33FFFFFF);

  static const heroFraction = 0.42;
  static const backButtonSize = 40.0;
  static const featureIconSize = 40.0;
  static const buttonRadius = 20.0;
}
