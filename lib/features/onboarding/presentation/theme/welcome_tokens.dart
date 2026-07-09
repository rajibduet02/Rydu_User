import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Welcome / first-ride help screen (Figma + React `WelcomeScreen.tsx` reference).
abstract final class WelcomeTokens {
  static const bg = AppDarkSurfaces.scaffold;

  static const accent = AppBrand.primaryDark;
  static const accentSoft = AppBrand.primaryLight;

  static const cardStart = AppDarkSurfaces.surfaceContainerLow;
  static const cardEnd = AppDarkSurfaces.scaffold;
  static const rideCardFill = AppDarkSurfaces.surfaceContainerLow;
  static const rideCardGlow = AppBrand.primaryDark;

  static const border = AppDarkSurfaces.border;

  static const muted = AppDarkText.muted;
  static const white = Color(0xFFFFFFFF);
  static const buttonFill = Color(0xFFFFFFFF);
  static const buttonText = AppDarkSurfaces.scaffold;

  static const discountRed = Color(0xFFFF0000);

  static const double radiusPromo = 12;
  static const double radiusHero = 24;
  static const double radiusButton = 999;

  static const double spaceHorizontal = 24;
  static const double spaceSectionBottom = 24;
  static const double spaceBottom = 32;
  static const double spaceBetweenTitleAndButtons = 24;
  static const double spaceBetweenButtons = 12;

  static const double promoCardWidth = 80;
  static const double promoCardHeight = 96;
  static const double promoGap = 12;

  static const double titleBottom = 12;
}
