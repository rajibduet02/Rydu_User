import 'package:flutter/material.dart';
import 'package:rydu_user/app/theme/app_colors.dart';

/// Light tonal palette for Sign In / Sign Up — derived from [#2F6BFF] seed.
///
/// Reference: `ColorScheme.fromSeed(seedColor: AppBrand.seed, brightness: light)`.
abstract final class AuthLightTonalTokens {
  static const authScaffold = AppBrand.primary;

  /// Outer field card — `primaryContainer`.
  static const authFormSurface = Color(0xFFFFDBD0);

  /// Inner text field — `surfaceContainerLow`.
  static const authInputSurface = Color(0xFFFFF1ED);

  /// Focused input fill — `surfaceContainerLowest`.
  static const authInputFocusedSurface = Color(0xFFFFFFFF);

  /// Normal border — `outlineVariant`.
  static const authBorder = Color(0xFFD8C2BB);

  /// Focused border — seed primary.
  static const authFocusedBorder = AppBrand.primary;

  /// Primary readable text — `onSurface`.
  static const authTextPrimary = Color(0xFF231917);

  /// Secondary labels — `onSurfaceVariant`.
  static const authTextSecondary = Color(0xFF53433F);

  /// Hint text — muted warm neutral.
  static const authHintText = Color(0xFF85736E);

  /// Icons — warm muted neutral.
  static const authIcon = Color(0xFF85736E);

  /// Enabled CTA background — stands out on coral scaffold.
  static const authPrimaryAction = Color(0xFFFFFFFF);

  /// CTA label — warm dark neutral.
  static const authOnPrimaryAction = Color(0xFF231917);

  /// Pressed CTA — `surfaceContainerHigh`.
  static const authPrimaryActionPressed = Color(0xFFF7E4DF);

  /// Disabled CTA surface.
  static const authDisabledSurface = Color(0xFFFFF1ED);

  /// Disabled CTA label.
  static const authDisabledText = Color(0xFF85736E);

  /// Warm card shadow tint — `onPrimaryContainer` at low alpha.
  static const authCardShadow = Color(0x1F723520);

  /// Page title on coral scaffold.
  static const authTitleOnScaffold = Color(0xFFFFFFFF);

  /// Subtitle on coral scaffold.
  static const authSubtitleOnScaffold = Color(0xE6FFFFFF);

  /// Link / accent on coral scaffold — `onPrimaryContainer`.
  static const authLinkOnScaffold = Color(0xFF723520);
}
