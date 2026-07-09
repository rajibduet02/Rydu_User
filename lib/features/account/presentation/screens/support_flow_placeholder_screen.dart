import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../theme/help_center_tokens.dart';

/// Placeholder for support sub-flows until real screens exist.
class SupportFlowPlaceholderScreen extends StatelessWidget {
  const SupportFlowPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HelpCenterTokens.background,
      appBar: AppBar(
        backgroundColor: HelpCenterTokens.background,
        foregroundColor: HelpCenterTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.account);
            }
          },
        ),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$title will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: HelpCenterTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
