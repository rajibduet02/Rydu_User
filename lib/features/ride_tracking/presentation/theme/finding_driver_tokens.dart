import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Finding driver / ride requested screen tokens.
abstract final class FindingDriverTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const mapTop = AppDarkSurfaces.border;
  static const mapBottom = AppDarkSurfaces.surfaceContainerLow;
  static const card = AppDarkSurfaces.surface;
  static const cardInner = AppDarkSurfaces.surfaceContainerLow;
  static const border = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const accent = AppBrand.primary;
  static const accentLight = Color(0xFF4D7DFF);
  static const active = Color(0xFF22C55E);
}
