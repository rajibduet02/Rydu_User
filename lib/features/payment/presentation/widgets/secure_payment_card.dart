import 'package:flutter/material.dart';

import '../theme/add_card_tokens.dart';

class SecurePaymentCard extends StatelessWidget {
  const SecurePaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.035).clamp(13.0, 14.0);
    final bodySize = (w * 0.03).clamp(11.5, 12.5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AddCardTokens.secureFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AddCardTokens.secureBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: AddCardTokens.accent,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your payment is secure',
                  style: TextStyle(
                    color: AddCardTokens.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'We use encryption to protect your card information. Your details are never shared with drivers.',
                  style: TextStyle(
                    color: AddCardTokens.muted,
                    fontSize: bodySize,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
