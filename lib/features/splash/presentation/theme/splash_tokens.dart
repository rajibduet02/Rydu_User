import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Splash screen — product reference (solid dark frame + white type + blue dots).
abstract final class SplashTokens {
  /// Solid deep navy from design reference (~`#0B1221`).
  static const background = AppDarkSurfaces.scaffold;

  static const white = Color(0xFFFFFFFF);

  /// Loading dots — brand primary (~`#2F6BFF`).
  static const dotBlue = AppBrand.primary;
}
