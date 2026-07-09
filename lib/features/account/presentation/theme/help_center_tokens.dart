import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Help Center (Figma + `HelpCenterScreen.tsx`).
abstract final class HelpCenterTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const cardTop = AppDarkSurfaces.surface;
  static const cardBottom = AppDarkSurfaces.surfaceContainerLow;
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const muted = AppDarkText.secondary;
  static const white = Color(0xFFFFFFFF);
  static const accent = AppBrand.primary;
  static const accentSoft = Color(0xFF4D7DFF);

  static const liveChat = AppBrand.primary;
  static const call = Color(0xFF22C55E);
  static const email = Color(0xFFF59E0B);
  static const faq = Color(0xFF8B5CF6);
  static const rideIssue = Color(0xFFEF4444);
  static const lostItem = Color(0xFFEC4899);
  static const safety = Color(0xFF10B981);
}
