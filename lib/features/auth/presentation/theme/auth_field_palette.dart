import 'package:flutter/material.dart';

import 'auth_light_tonal_tokens.dart';
import 'auth_screen_tokens.dart';

/// Semantic color roles for [AuthLabeledField] — dark (default) or light tonal.
class AuthFieldPalette {
  const AuthFieldPalette({
    required this.formSurface,
    required this.inputSurface,
    required this.inputFocusedSurface,
    required this.border,
    required this.focusedBorder,
    required this.labelColor,
    required this.textColor,
    required this.hintColor,
    required this.cardShadow,
  });

  final Color formSurface;
  final Color inputSurface;
  final Color inputFocusedSurface;
  final Color border;
  final Color focusedBorder;
  final Color labelColor;
  final Color textColor;
  final Color hintColor;
  final Color cardShadow;

  /// Dark navy palette — used by forgot/reset password and other auth flows.
  static const dark = AuthFieldPalette(
    formSurface: AuthScreenTokens.card,
    inputSurface: AuthScreenTokens.field,
    inputFocusedSurface: AuthScreenTokens.field,
    border: AuthScreenTokens.border,
    focusedBorder: AuthScreenTokens.accent,
    labelColor: AuthScreenTokens.muted,
    textColor: AuthScreenTokens.white,
    hintColor: Color(0x809CA3AF),
    cardShadow: Color(0x33000000),
  );

  /// Light peach palette — Sign In and Sign Up only.
  static const light = AuthFieldPalette(
    formSurface: AuthLightTonalTokens.authFormSurface,
    inputSurface: AuthLightTonalTokens.authInputSurface,
    inputFocusedSurface: AuthLightTonalTokens.authInputFocusedSurface,
    border: AuthLightTonalTokens.authBorder,
    focusedBorder: AuthLightTonalTokens.authFocusedBorder,
    labelColor: AuthLightTonalTokens.authTextSecondary,
    textColor: AuthLightTonalTokens.authTextPrimary,
    hintColor: Color(0xB885736E),
    cardShadow: AuthLightTonalTokens.authCardShadow,
  );
}
