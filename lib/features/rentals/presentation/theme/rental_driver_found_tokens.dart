import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Rental driver found — screenshot / React alignment.
abstract final class RentalDriverFoundTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const sheet = AppDarkSurfaces.scaffold;
  static const card = AppDarkSurfaces.surface;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const accent = AppBrand.primary;
  static const accentAlt = AppBrand.primary;
  static const white = Color(0xFFFFFFFF);
  static const muted = AppDarkText.secondary;
  static const mapTop = AppDarkSurfaces.border;
  static const mapBottom = AppDarkSurfaces.surfaceContainerLow;
  static const reminderFill = Color(0x1A2F6BFF); // ~10% primary
  static const reminderBorder = AppBrand.primaryBorder; // ~30% primary

  static const backSize = 40.0;
  static const cardRadius = 16.0;
  static const driverCardRadius = 24.0;
  static const sheetTopRadius = 32.0;
}
