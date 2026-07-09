import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/call_support_tokens.dart';

/// Placeholder until callback request form / API is implemented.
class RequestCallbackScreen extends StatelessWidget {
  const RequestCallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CallSupportTokens.background,
      appBar: AppBar(
        backgroundColor: CallSupportTokens.background,
        foregroundColor: CallSupportTokens.white,
        elevation: 0,
        title: const Text('Request a Callback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            // TODO: Callback form (name, phone, preferred time) and submit to support API.
            'TODO: Request callback form will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CallSupportTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
