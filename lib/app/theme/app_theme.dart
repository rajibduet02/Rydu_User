import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme =>
      _buildTheme(palette: AppColors.dark, brightness: Brightness.dark);

  static ThemeData get lightTheme =>
      _buildTheme(palette: AppColors.light, brightness: Brightness.light);

  /// Legacy alias — prefer [darkTheme].
  static ThemeData get dark => darkTheme;

  /// Legacy alias — prefer [lightTheme].
  static ThemeData get light => lightTheme;

  /// Material 3 dark [ColorScheme] from [#2F6BFF] seed with tuned surfaces.
  static ColorScheme darkColorScheme(AppColors palette) {
    final generated = ColorScheme.fromSeed(
      seedColor: AppBrand.seed,
      brightness: Brightness.dark,
    );

    return generated.copyWith(
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.primaryLight,
      secondary: generated.secondary,
      onSecondary: generated.onSecondary,
      secondaryContainer: generated.secondaryContainer,
      onSecondaryContainer: generated.onSecondaryContainer,
      tertiary: generated.tertiary,
      onTertiary: generated.onTertiary,
      surface: palette.background,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      surfaceContainerLowest: palette.background,
      surfaceContainerLow: AppDarkSurfaces.surfaceContainerLow,
      surfaceContainer: palette.surface,
      surfaceContainerHigh: palette.surfaceElevated,
      surfaceContainerHighest: const Color(0xFF1E293B),
      outline: palette.cardBorder,
      outlineVariant: palette.borderSubtle,
      error: palette.danger,
      onError: palette.textPrimary,
      scrim: Colors.black,
      shadow: Colors.black,
    );
  }

  /// Material 3 light [ColorScheme] from [#2F6BFF] seed.
  static ColorScheme lightColorScheme(AppColors palette) {
    final generated = ColorScheme.fromSeed(
      seedColor: AppBrand.seed,
      brightness: Brightness.light,
    );

    return generated.copyWith(
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.primaryDark,
      surface: palette.background,
      onSurface: palette.textPrimary,
      onSurfaceVariant: palette.textSecondary,
      outline: palette.cardBorder,
      outlineVariant: palette.borderSubtle,
      error: palette.danger,
      onError: Colors.white,
    );
  }

  static ThemeData _buildTheme({
    required AppColors palette,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? darkColorScheme(palette)
        : lightColorScheme(palette);

    final borderRadius = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[AppThemeColors(palette)],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.cardBorder, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputSurface,
        hintStyle: TextStyle(color: palette.textMuted),
        labelStyle: TextStyle(color: palette.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: palette.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: palette.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: palette.danger),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.cardBorder,
        circularTrackColor: palette.cardBorder,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: palette.primary, fontSize: 12);
          }
          return TextStyle(color: palette.textMuted, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.primary);
          }
          return IconThemeData(color: palette.textMuted);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: palette.textMuted,
        indicatorColor: palette.primary,
        dividerColor: palette.cardBorder,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceElevated,
        selectedColor: palette.primaryContainer,
        disabledColor: palette.disabled,
        labelStyle: TextStyle(color: palette.textPrimary),
        secondaryLabelStyle: TextStyle(color: palette.textSecondary),
        side: BorderSide(color: palette.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return palette.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary.withValues(alpha: 0.45);
          }
          return palette.cardBorder;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return palette.surfaceElevated;
        }),
        checkColor: WidgetStateProperty.all(palette.onPrimary),
        side: BorderSide(color: palette.cardBorder, width: 2),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.primary;
          return palette.textMuted;
        }),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: palette.primary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return palette.disabled;
            if (states.contains(WidgetState.pressed)) {
              return palette.primaryDark;
            }
            return palette.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.textDisabled;
            }
            return palette.onPrimary;
          }),
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: borderRadius),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return palette.disabled;
            if (states.contains(WidgetState.pressed)) {
              return palette.primaryDark;
            }
            return palette.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return palette.textDisabled;
            }
            return palette.onPrimary;
          }),
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: borderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.cardBorder, width: 2),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.primary,
        selectionColor: palette.primarySoft,
        selectionHandleColor: palette.primary,
      ),
      textTheme: _textTheme(palette),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  static TextTheme _textTheme(AppColors palette) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: palette.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: palette.textMuted,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: palette.textSecondary,
      ),
    );
  }
}
