import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shared_preferences_provider.dart';

const _storageKey = 'rydu_theme_mode';
const _valueDark = 'dark';
const _valueLight = 'light';

class AppThemeModeState {
  const AppThemeModeState({
    this.themeMode = ThemeMode.dark,
    this.isLoading = false,
    this.errorMessage,
  });

  final ThemeMode themeMode;
  final bool isLoading;
  final String? errorMessage;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  AppThemeModeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppThemeModeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AppThemeModeController extends Notifier<AppThemeModeState> {
  @override
  AppThemeModeState build() {
    Future.microtask(loadThemeMode);
    return const AppThemeModeState(isLoading: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> loadThemeMode() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final saved = prefs.getString(_storageKey);
      final mode = _themeModeFromStorage(saved);
      state = AppThemeModeState(themeMode: mode, isLoading: false);
    } catch (e) {
      state = AppThemeModeState(
        themeMode: ThemeMode.dark,
        isLoading: false,
        errorMessage: 'Could not load theme preference.',
      );
    }
  }

  Future<void> setDarkMode(bool value) async {
    final mode = value ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: mode, clearError: true);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_storageKey, value ? _valueDark : _valueLight);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not save theme preference.');
    }
  }

  Future<void> toggleThemeMode() async {
    await setDarkMode(!state.isDarkMode);
  }

  ThemeMode _themeModeFromStorage(String? value) {
    if (value == _valueLight) return ThemeMode.light;
    return ThemeMode.dark;
  }
}

final appThemeModeProvider =
    NotifierProvider<AppThemeModeController, AppThemeModeState>(
      AppThemeModeController.new,
    );
