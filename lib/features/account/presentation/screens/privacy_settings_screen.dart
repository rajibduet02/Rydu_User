import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/settings_screen_tokens.dart';

/// Placeholder until privacy controls are implemented.
class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsScreenTokens.background,
      appBar: AppBar(
        backgroundColor: SettingsScreenTokens.background,
        foregroundColor: SettingsScreenTokens.white,
        elevation: 0,
        title: const Text('Privacy Settings'),
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
            // TODO: Tie to privacy policy, data export, and ad/analytics toggles when legal product spec is ready.
            'TODO: Privacy controls and data preferences.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SettingsScreenTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
