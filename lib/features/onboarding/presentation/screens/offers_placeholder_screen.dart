import 'package:flutter/material.dart';

import '../theme/welcome_tokens.dart';

/// Placeholder hub for promo / offers list until product content exists.
class OffersPlaceholderScreen extends StatelessWidget {
  const OffersPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WelcomeTokens.bg,
      appBar: AppBar(
        backgroundColor: WelcomeTokens.bg,
        foregroundColor: WelcomeTokens.white,
        elevation: 0,
        title: const Text('Offers'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Offers will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: WelcomeTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
