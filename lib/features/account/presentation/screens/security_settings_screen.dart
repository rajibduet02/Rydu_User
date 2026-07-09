import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/settings_screen_tokens.dart';

/// Placeholder until password / MFA flows are implemented.
class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SettingsScreenTokens.background,
      appBar: AppBar(
        backgroundColor: SettingsScreenTokens.background,
        foregroundColor: SettingsScreenTokens.white,
        elevation: 0,
        title: const Text('Security'),
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
            // TODO: Link change password, biometrics, and session management to auth service.
            'TODO: Password and authentication settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SettingsScreenTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
