import 'package:flutter/material.dart';

import '../theme/add_card_tokens.dart';

class SaveCardTile extends StatelessWidget {
  const SaveCardTile({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final subSize = (w * 0.033).clamp(12.5, 13.5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AddCardTokens.fieldFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AddCardTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save card for future rides',
                  style: TextStyle(
                    color: AddCardTokens.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Securely store your card details',
                  style: TextStyle(
                    color: AddCardTokens.muted,
                    fontSize: subSize,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AddCardTokens.accent.withValues(alpha: 0.55),
            inactiveTrackColor: AddCardTokens.border,
            activeThumbColor: AddCardTokens.white,
            inactiveThumbColor: AddCardTokens.white,
          ),
        ],
      ),
    );
  }
}
