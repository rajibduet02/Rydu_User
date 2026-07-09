import 'package:flutter/material.dart';

import '../models/confidence_item.dart';
import '../theme/intercity_tokens.dart';

class RideConfidenceCard extends StatelessWidget {
  const RideConfidenceCard({super.key, required this.item});

  final ConfidenceItem item;

  IconData _iconFor(ConfidenceIconType t) {
    switch (t) {
      case ConfidenceIconType.award:
        return Icons.workspace_premium_outlined;
      case ConfidenceIconType.shield:
        return Icons.verified_user_outlined;
      case ConfidenceIconType.calendar:
        return Icons.calendar_today_outlined;
      case ConfidenceIconType.mapPin:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IntercityTokens.cardFill,
        borderRadius: BorderRadius.circular(IntercityTokens.radiusLg),
        border: Border.all(color: IntercityTokens.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: IntercityTokens.iconWell,
            ),
            alignment: Alignment.center,
            child: Icon(
              _iconFor(item.iconType),
              color: IntercityTokens.accent,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: IntercityTokens.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
