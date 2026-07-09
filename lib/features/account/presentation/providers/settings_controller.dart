import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme_mode_provider.dart';
import 'account_dependencies.dart';

class SettingsState {
  const SettingsState({
    this.notificationsEnabled = true,
    this.darkModeEnabled = true,
    this.selectedLanguage = 'English (US)',
    this.appVersion = '4.629.10001',
    this.isLoading = false,
    this.errorMessage,
  });

  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String selectedLanguage;
  final String appVersion;
  final bool isLoading;
  final String? errorMessage;

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? selectedLanguage,
    String? appVersion,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      appVersion: appVersion ?? this.appVersion,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() => const SettingsState();

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final themeNotifier = ref.read(appThemeModeProvider.notifier);
      if (ref.read(appThemeModeProvider).isLoading) {
        await themeNotifier.loadThemeMode();
      }
      final isDark = ref.read(appThemeModeProvider).isDarkMode;
      final settings = await ref.read(getAccountSettingsUsecaseProvider).call();
      state = state.copyWith(
        isLoading: false,
        darkModeEnabled: isDark,
        notificationsEnabled: settings.notificationsEnabled,
        selectedLanguage: settings.selectedLanguage,
        appVersion: settings.appVersion,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load settings.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value, clearError: true);
  }

  Future<void> toggleDarkMode(bool value) async {
    await ref.read(appThemeModeProvider.notifier).setDarkMode(value);
    state = state.copyWith(darkModeEnabled: value, clearError: true);
  }

  void openLanguageSettings() {
    ref.read(goRouterProvider).push(RouteNames.languageSettings);
  }

  void openPrivacySettings() {
    ref.read(goRouterProvider).push(RouteNames.privacySettings);
  }

  void openSecuritySettings() {
    ref.read(goRouterProvider).push(RouteNames.securitySettings);
  }
}
