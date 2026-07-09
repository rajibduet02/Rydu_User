import 'package:flutter/material.dart';

import '../theme/rental_driver_found_tokens.dart';

class RentalDetailsCard extends StatelessWidget {
  const RentalDetailsCard({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.startingPoint,
    required this.rentalId,
    required this.durationLabel,
    required this.paymentMethod,
    required this.onShare,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final String startingPoint;
  final String rentalId;
  final String durationLabel;
  final String paymentMethod;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.04).clamp(15.0, 16.0);
    final labelSize = (w * 0.035).clamp(13.0, 14.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(
              RentalDriverFoundTokens.cardRadius,
            ),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: RentalDriverFoundTokens.card,
                borderRadius: BorderRadius.circular(
                  RentalDriverFoundTokens.cardRadius,
                ),
                border: Border.all(color: RentalDriverFoundTokens.border),
              ),
              child: Row(
                children: [
                  Text(
                    'Rental details',
                    style: TextStyle(
                      color: RentalDriverFoundTokens.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: RentalDriverFoundTokens.muted,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RentalDriverFoundTokens.card,
                borderRadius: BorderRadius.circular(
                  RentalDriverFoundTokens.cardRadius,
                ),
                border: Border.all(color: RentalDriverFoundTokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: RentalDriverFoundTokens.accentAlt,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Starting point',
                              style: TextStyle(
                                color: RentalDriverFoundTokens.muted,
                                fontSize: labelSize,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              startingPoint,
                              style: TextStyle(
                                color: RentalDriverFoundTokens.white,
                                fontSize: labelSize + 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: RentalDriverFoundTokens.border),
                  const SizedBox(height: 14),
                  _row('Rental ID', rentalId, labelSize),
                  const SizedBox(height: 12),
                  _row('Duration', durationLabel, labelSize),
                  const SizedBox(height: 12),
                  _row('Payment', paymentMethod, labelSize),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: RentalDriverFoundTokens.border),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onShare,
                    style: TextButton.styleFrom(
                      foregroundColor: RentalDriverFoundTokens.accentAlt,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: Text(
                      'Share trip status',
                      style: TextStyle(
                        fontSize: labelSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  static Widget _row(String label, String value, double labelSize) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: RentalDriverFoundTokens.muted,
              fontSize: labelSize,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: RentalDriverFoundTokens.white,
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
