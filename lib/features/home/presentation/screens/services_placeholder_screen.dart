import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/home_screen_tokens.dart';

class ServicesPlaceholderScreen extends StatelessWidget {
  const ServicesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeScreenTokens.background,
      appBar: AppBar(
        backgroundColor: HomeScreenTokens.background,
        foregroundColor: HomeScreenTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Services'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Services hub will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: HomeScreenTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
