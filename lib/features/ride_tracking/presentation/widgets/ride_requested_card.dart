import 'package:flutter/material.dart';

import '../theme/finding_driver_tokens.dart';

class RideRequestedCard extends StatelessWidget {
  const RideRequestedCard({
    super.key,
    required this.pickupSpotName,
    this.fareLabel,
  });

  final String pickupSpotName;
  final String? fareLabel;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final bodySize = (w * 0.034).clamp(13.0, 14.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FindingDriverTokens.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FindingDriverTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: FindingDriverTokens.accent,
                ),
                alignment: Alignment.center,
                child: const Text('📍', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meet at the pickup spot for',
                      style: TextStyle(
                        color: FindingDriverTokens.muted,
                        fontSize: bodySize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pickupSpotName,
                      style: TextStyle(
                        color: FindingDriverTokens.white,
                        fontWeight: FontWeight.w600,
                        fontSize: titleSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '● Active',
                      style: TextStyle(
                        color: FindingDriverTokens.active,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FindingDriverTokens.cardInner,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quality rides, every time',
                  style: TextStyle(
                    color: FindingDriverTokens.white,
                    fontWeight: FontWeight.w600,
                    fontSize: titleSize,
                  ),
                ),
                if (fareLabel != null && fareLabel!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    fareLabel!,
                    style: TextStyle(
                      color: FindingDriverTokens.white,
                      fontWeight: FontWeight.w700,
                      fontSize: titleSize,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Waiting for a nearby driver to accept your ride.',
                  style: TextStyle(
                    color: FindingDriverTokens.muted,
                    fontSize: bodySize,
                    height: 1.4,
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
