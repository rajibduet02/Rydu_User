import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/auth_screen_tokens.dart';

/// Placeholder until legal content is wired.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key, this.appBarTitle = 'Privacy Policy'});

  final String appBarTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthScreenTokens.bg,
      appBar: AppBar(
        backgroundColor: AuthScreenTokens.bg,
        foregroundColor: AuthScreenTokens.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(appBarTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Privacy Policy content will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AuthScreenTokens.muted.withValues(alpha: 0.95),
            ),
          ),
        ),
      ),
    );
  }
}
