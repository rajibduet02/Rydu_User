import 'package:flutter/material.dart';

import '../providers/welcome_controller.dart';
import '../theme/welcome_tokens.dart';
import 'welcome_action_button.dart';

class WelcomeCtaSection extends StatelessWidget {
  const WelcomeCtaSection({
    super.key,
    required this.submitKind,
    required this.onNeedHelp,
    required this.onNoThanks,
  });

  final WelcomeSubmitKind submitKind;
  final VoidCallback onNeedHelp;
  final VoidCallback onNoThanks;

  @override
  Widget build(BuildContext context) {
    final busy = submitKind != WelcomeSubmitKind.none;
    final helpLoading = submitKind == WelcomeSubmitKind.help;
    final skipLoading = submitKind == WelcomeSubmitKind.skip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WelcomeActionButton.primary(
          label: 'Yes, I need help',
          isLoading: helpLoading,
          onPressed: busy ? null : onNeedHelp,
        ),
        const SizedBox(height: WelcomeTokens.spaceBetweenButtons),
        WelcomeActionButton.secondary(
          label: 'No, Thanks',
          isLoading: skipLoading,
          onPressed: busy ? null : onNoThanks,
        ),
      ],
    );
  }
}
