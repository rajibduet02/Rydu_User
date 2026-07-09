import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Inbox (Figma + `InboxScreen.tsx`).
abstract final class InboxTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const cardTop = AppDarkSurfaces.surface;
  static const cardBottom = Color(0xFF141B2D);
  static const iconWell = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const borderUnread = Color(0x802F6BFF);
  static const muted = Color(0xFF94A3B8);
  static const white = Color(0xFFFFFFFF);
  static const accent = AppBrand.primary;
}
