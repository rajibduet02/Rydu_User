import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme_mode_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/settings_screen_tokens.dart';
import '../widgets/settings_footer.dart';
import '../widgets/settings_option_tile.dart';
import '../widgets/settings_switch_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(settingsControllerProvider.notifier).loadSettings();
    });
  }

  void _popOrAccount(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SettingsScreenTokens.cardTop,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsControllerProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final c = ref.read(settingsControllerProvider.notifier);
    final isDarkMode = themeMode.isDarkMode;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.055).clamp(18.0, 24.0);
    final titleSize = (w * 0.065).clamp(22.0, 28.0);
    final sectionSize = (w * 0.045).clamp(16.0, 18.0);
    final sectionGap = (w * 0.055).clamp(22.0, 28.0);
    final cardGap = (w * 0.03).clamp(10.0, 12.0);

    return Scaffold(
      backgroundColor: SettingsScreenTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SettingsScreenTokens.iconWell,
                      border: Border.all(color: SettingsScreenTokens.border),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _popOrAccount(context),
                        child: Padding(
                          padding: EdgeInsets.all(
                            (w * 0.028).clamp(10.0, 12.0),
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: SettingsScreenTokens.white,
                            size: (w * 0.07).clamp(26.0, 30.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        color: SettingsScreenTokens.white,
                        fontWeight: FontWeight.w800,
                        fontSize: titleSize,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: (w * 0.045).clamp(16.0, 20.0)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: const Divider(
                height: 1,
                thickness: 1,
                color: SettingsScreenTokens.border,
              ),
            ),
            if (s.errorMessage != null)
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                child: Text(
                  s.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(hPad, sectionGap, hPad, 8),
                children: [
                  Text(
                    'Preferences',
                    style: TextStyle(
                      color: SettingsScreenTokens.white,
                      fontWeight: FontWeight.w800,
                      fontSize: sectionSize,
                    ),
                  ),
                  SizedBox(height: (w * 0.035).clamp(14.0, 16.0)),
                  SettingsSwitchTile(
                    title: 'Notifications',
                    subtitle: s.notificationsEnabled
                        ? 'Ride alerts are on'
                        : 'Ride alerts are off',
                    icon: Icons.notifications_none_rounded,
                    value: s.notificationsEnabled,
                    onChanged: (value) async {
                      await c.toggleNotifications(value);
                      if (!context.mounted) return;
                      final enabled = ref
                          .read(settingsControllerProvider)
                          .notificationsEnabled;
                      _snack(
                        context,
                        value && !enabled
                            ? 'Notifications stay off until you allow them in system settings.'
                            : enabled
                            ? 'Ride notifications on'
                            : 'Ride notifications off',
                      );
                    },
                  ),
                  SizedBox(height: cardGap),
                  SettingsSwitchTile(
                    title: 'Dark Mode',
                    subtitle: isDarkMode ? 'On' : 'Off',
                    icon: Icons.dark_mode_outlined,
                    value: isDarkMode,
                    onChanged: (value) => c.toggleDarkMode(value),
                  ),
                  SizedBox(height: cardGap),
                  SettingsOptionTile(
                    title: 'Language',
                    subtitle: s.selectedLanguage,
                    icon: Icons.language_rounded,
                    onTap: c.openLanguageSettings,
                  ),
                  SizedBox(height: sectionGap + 4),
                  Text(
                    'Privacy & Security',
                    style: TextStyle(
                      color: SettingsScreenTokens.white,
                      fontWeight: FontWeight.w800,
                      fontSize: sectionSize,
                    ),
                  ),
                  SizedBox(height: (w * 0.035).clamp(14.0, 16.0)),
                  SettingsOptionTile(
                    title: 'Privacy Settings',
                    subtitle: 'Control your data and privacy',
                    icon: Icons.lock_outline_rounded,
                    onTap: c.openPrivacySettings,
                  ),
                  SizedBox(height: cardGap),
                  SettingsOptionTile(
                    title: 'Security',
                    subtitle: 'Password and authentication',
                    icon: Icons.lock_outline_rounded,
                    onTap: c.openSecuritySettings,
                  ),
                  SettingsFooter(appVersion: s.appVersion),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
