import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/settings_screen_tokens.dart';

/// Placeholder until language / locale picker is implemented.
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsScreenTokens.background,
      appBar: AppBar(
        backgroundColor: SettingsScreenTokens.background,
        foregroundColor: SettingsScreenTokens.white,
        elevation: 0,
        title: const Text('Language'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            // TODO: List supported locales and persist choice via profile/settings API.
            'TODO: Language selection UI and persistence.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SettingsScreenTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
