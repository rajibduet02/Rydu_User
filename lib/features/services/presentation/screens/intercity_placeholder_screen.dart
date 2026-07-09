import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/services_screen_tokens.dart';

class IntercityPlaceholderScreen extends StatelessWidget {
  const IntercityPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ServicesScreenTokens.background,
      appBar: AppBar(
        backgroundColor: ServicesScreenTokens.background,
        foregroundColor: ServicesScreenTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Intercity'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Intercity trips will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ServicesScreenTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
