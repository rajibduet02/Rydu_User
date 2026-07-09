import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/safety_resources_tokens.dart';

/// Placeholder until full SOS guide content and emergency flows exist.
class SosGuideScreen extends StatelessWidget {
  const SosGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SafetyResourcesTokens.background,
      appBar: AppBar(
        backgroundColor: SafetyResourcesTokens.background,
        foregroundColor: SafetyResourcesTokens.white,
        elevation: 0,
        title: const Text('SOS Guide'),
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
            // TODO: In-app SOS steps, emergency contacts, and regional hotlines.
            'TODO: SOS guide content will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SafetyResourcesTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
