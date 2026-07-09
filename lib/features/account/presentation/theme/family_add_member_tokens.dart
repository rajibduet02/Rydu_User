import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Family add-member flow (screenshot reference).
abstract final class FamilyAddMemberTokens {
  static const background = AppDarkSurfaces.scaffold;
  static const card = AppDarkSurfaces.surface;
  static const field = AppDarkSurfaces.inputSurface;
  static const pillButton = AppDarkSurfaces.surfaceSelected;
  static const divider = AppDarkSurfaces.border;
  static const muted = AppDarkText.muted;
  static const white = Color(0xFFFFFFFF);
  static const continueEnabled = Color(0xFFE5E5E5);
  static const continueDisabled = AppDarkSurfaces.surfaceContainerLow;
  static const continueText = Color(0xFF000000);
  static const continueTextDisabled = AppDarkText.disabled;
  static const fieldBorder = AppDarkSurfaces.border;
  static const fieldBorderMuted = AppDarkSurfaces.borderSubtle;
  static const sendEnabled = Color(0xFFE5E5E5);
  static const sendDisabled = AppDarkSurfaces.surfaceContainerLow;
}
