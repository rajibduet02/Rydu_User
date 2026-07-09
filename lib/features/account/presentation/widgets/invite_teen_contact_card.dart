import 'package:flutter/material.dart';

import '../theme/invite_teen_tokens.dart';

class InviteTeenContactCard extends StatelessWidget {
  const InviteTeenContactCard({super.key, required this.onChooseContacts});

  final VoidCallback onChooseContacts;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.042).clamp(15.0, 17.0);
    final subtitleSize = (w * 0.034).clamp(13.0, 14.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InviteTeenTokens.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save time',
                  style: TextStyle(
                    color: InviteTeenTokens.white,
                    fontWeight: FontWeight.w700,
                    fontSize: titleSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Import contact info to fill the fo...',
                  style: TextStyle(
                    color: InviteTeenTokens.muted,
                    fontSize: subtitleSize,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onChooseContacts,
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: InviteTeenTokens.pillButton,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Choose from contacts',
                  style: TextStyle(
                    color: InviteTeenTokens.white,
                    fontWeight: FontWeight.w600,
                    fontSize: (w * 0.03).clamp(11.0, 12.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
