import 'package:flutter/material.dart';

/// Global brand + dark surface constants — source of truth for feature tokens.
abstract final class AppBrand {
  /// Material 3 seed color anchor — Figma/reference primary blue.
  static const seed = Color(0xFF2F6BFF);

  static const primary = seed;
  static const primaryLight = Color(0xFF4D7DFF);
  static const primaryDark = Color(0xFF2962FF);
  static const primarySoft = Color(0x332F6BFF);
  static const primaryContainer = Color(0xFF1A2F55);
  static const primaryBorder = Color(0x662F6BFF);
  static const primaryGlow = Color(0x4D2F6BFF);
  static const onPrimary = Color(0xFFFFFFFF);
}

/// Premium dark surface hierarchy — Figma `theme.css` navy surfaces.
abstract final class AppDarkSurfaces {
  static const scaffold = Color(0xFF060B14);
  static const surface = Color(0xFF111827);
  static const surfaceElevated = Color(0xFF182235);
  static const surfaceContainerLow = Color(0xFF0D1523);
  static const surfaceSelected = Color(0xFF1A2F55);
  static const inputSurface = Color(0xFF182235);
  static const border = Color(0xFF2A3548);
  static const borderSubtle = Color(0xFF1F2937);
}

/// Dark-theme text hierarchy.
abstract final class AppDarkText {
  static const primary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFB8C0D4);
  static const muted = Color(0xFF9CA3AF);
  static const disabled = Color(0xFF6B7280);
}

/// Semantic color palette for light and dark themes.
class AppColors {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceElevated,
    required this.inputSurface,
    required this.surfaceSelected,
    required this.card,
    required this.cardBorder,
    required this.borderSubtle,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primarySoft,
    required this.primaryContainer,
    required this.primaryBorder,
    required this.primaryGlow,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.danger,
    required this.disabled,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceElevated;
  final Color inputSurface;
  final Color surfaceSelected;
  final Color card;
  final Color cardBorder;
  final Color borderSubtle;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primarySoft;
  final Color primaryContainer;
  final Color primaryBorder;
  final Color primaryGlow;
  final Color onPrimary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color success;
  final Color warning;
  final Color danger;
  final Color disabled;

  /// Production dark palette — seed-harmonized Material 3 tonal hierarchy.
  static const dark = AppColors(
    background: AppDarkSurfaces.scaffold,
    surface: AppDarkSurfaces.surface,
    surfaceAlt: AppDarkSurfaces.inputSurface,
    surfaceElevated: AppDarkSurfaces.surfaceElevated,
    inputSurface: AppDarkSurfaces.inputSurface,
    surfaceSelected: AppDarkSurfaces.surfaceSelected,
    card: AppDarkSurfaces.surface,
    cardBorder: AppDarkSurfaces.border,
    borderSubtle: AppDarkSurfaces.borderSubtle,
    primary: AppBrand.primary,
    primaryLight: AppBrand.primaryLight,
    primaryDark: AppBrand.primaryDark,
    primarySoft: AppBrand.primarySoft,
    primaryContainer: AppBrand.primaryContainer,
    primaryBorder: AppBrand.primaryBorder,
    primaryGlow: AppBrand.primaryGlow,
    onPrimary: AppBrand.onPrimary,
    textPrimary: AppDarkText.primary,
    textSecondary: AppDarkText.secondary,
    textMuted: AppDarkText.muted,
    textDisabled: AppDarkText.disabled,
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFDC2626),
    disabled: Color(0xFF2A3548),
  );

  /// Initial light palette for gradual screen migration.
  static const light = AppColors(
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F5F9),
    surfaceElevated: Color(0xFFE2E8F0),
    inputSurface: Color(0xFFF1F5F9),
    surfaceSelected: Color(0xFFEEF2FF),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE2E8F0),
    borderSubtle: Color(0xFFF1F5F9),
    primary: AppBrand.primary,
    primaryLight: AppBrand.primaryLight,
    primaryDark: AppBrand.primaryDark,
    primarySoft: AppBrand.primarySoft,
    primaryContainer: Color(0xFFEEF2FF),
    primaryBorder: Color(0x992F6BFF),
    primaryGlow: AppBrand.primaryGlow,
    onPrimary: AppBrand.onPrimary,
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF64748B),
    textDisabled: Color(0xFF94A3B8),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFDC2626),
    disabled: Color(0xFFE2E8F0),
  );
}

/// Theme extension for gradual migration from feature token files.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors(this.palette);

  final AppColors palette;

  static AppThemeColors? of(BuildContext context) {
    return Theme.of(context).extension<AppThemeColors>();
  }

  @override
  AppThemeColors copyWith({AppColors? palette}) {
    return AppThemeColors(palette ?? this.palette);
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return t < 0.5 ? this : other;
  }
}
