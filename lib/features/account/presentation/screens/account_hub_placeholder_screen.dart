import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/account_screen_tokens.dart';

/// Simple placeholder for account-linked hubs until real screens ship.
class AccountHubPlaceholderScreen extends StatelessWidget {
  const AccountHubPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AccountScreenTokens.background,
      appBar: AppBar(
        backgroundColor: AccountScreenTokens.background,
        foregroundColor: AccountScreenTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$title will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AccountScreenTokens.muted,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
