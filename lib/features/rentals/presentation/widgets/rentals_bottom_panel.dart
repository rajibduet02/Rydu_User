import 'package:flutter/material.dart';

import '../theme/rentals_tokens.dart';
import 'rentals_feature_tile.dart';

class RentalsBottomPanel extends StatelessWidget {
  const RentalsBottomPanel({
    super.key,
    required this.onGetStarted,
    this.errorMessage,
  });

  final VoidCallback onGetStarted;
  final String? errorMessage;

  static const _features = <({IconData icon, String text})>[
    (
      icon: Icons.schedule_outlined,
      text: 'Keep a car and driver for up to 12 hours',
    ),
    (
      icon: Icons.business_center_outlined,
      text:
          'Ideal for business meetings, tourist travel and multiple stop trips',
    ),
    (icon: Icons.front_hand_outlined, text: 'As many stops as you need'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final hPad = (MediaQuery.sizeOf(context).width * 0.06).clamp(20.0, 24.0);
    final titleSize = (MediaQuery.sizeOf(context).width * 0.1).clamp(
      38.0,
      48.0,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(RentalsTokens.panelTopRadius),
        topRight: Radius.circular(RentalsTokens.panelTopRadius),
      ),
      child: ColoredBox(
        color: RentalsTokens.panelBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RYD U',
                      style: TextStyle(
                        color: RentalsTokens.titleWhite,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      'Rentals',
                      style: TextStyle(
                        color: RentalsTokens.titleWhite,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 36),
                    for (var i = 0; i < _features.length; i++) ...[
                      if (i > 0) const SizedBox(height: 28),
                      RentalsFeatureTile(
                        icon: _features[i].icon,
                        text: _features[i].text,
                      ),
                    ],
                    if (errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16 + bottom),
              child: FilledButton(
                onPressed: onGetStarted,
                style: FilledButton.styleFrom(
                  backgroundColor: RentalsTokens.buttonFill,
                  foregroundColor: RentalsTokens.buttonText,
                  elevation: 4,
                  shadowColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      RentalsTokens.buttonRadius,
                    ),
                  ),
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text(
                  'Get started',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
