import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../models/inbox_message.dart';
import '../theme/inbox_tokens.dart';

/// Placeholder detail until a full message thread UI exists.
class InboxDetailScreen extends StatelessWidget {
  const InboxDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final msg = extra is InboxMessage ? extra : null;

    return Scaffold(
      backgroundColor: InboxTokens.background,
      appBar: AppBar(
        backgroundColor: InboxTokens.background,
        foregroundColor: InboxTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.inbox);
            }
          },
        ),
        title: Text(msg?.title ?? 'Message'),
      ),
      body: msg == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No message selected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: InboxTokens.muted, fontSize: 16),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    msg.subtitle,
                    style: const TextStyle(
                      color: InboxTokens.white,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    msg.time,
                    style: const TextStyle(
                      color: InboxTokens.muted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    // TODO: Full message body, attachments, and actions from API.
                    'Full message view will appear here.',
                    style: TextStyle(color: InboxTokens.muted, fontSize: 14),
                  ),
                ],
              ),
            ),
    );
  }
}
