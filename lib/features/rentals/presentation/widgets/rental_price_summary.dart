import 'package:flutter/material.dart';

import '../theme/rental_time_tokens.dart';

class RentalPriceSummary extends StatelessWidget {
  const RentalPriceSummary({
    super.key,
    required this.currentTotal,
    required this.originalTotal,
    required this.hourlyRateLabel,
    required this.onChooseRide,
  });

  final double currentTotal;
  final double originalTotal;
  final String hourlyRateLabel;
  final VoidCallback onChooseRide;

  static String _bdt(double v) => 'BDT${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: RentalTimeTokens.panelFill,
        border: Border(
          top: BorderSide(color: RentalTimeTokens.border, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Starting at',
            style: TextStyle(
              color: RentalTimeTokens.muted,
              fontSize: (w * 0.035).clamp(13.0, 14.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _bdt(currentTotal),
                style: TextStyle(
                  color: RentalTimeTokens.white,
                  fontSize: (w * 0.065).clamp(24.0, 28.0),
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: (w * 0.03).clamp(10.0, 14.0)),
              Text(
                _bdt(originalTotal),
                style: TextStyle(
                  color: RentalTimeTokens.muted,
                  fontSize: (w * 0.045).clamp(16.0, 18.0),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: RentalTimeTokens.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hourlyRateLabel,
            style: TextStyle(
              color: RentalTimeTokens.muted,
              fontSize: (w * 0.035).clamp(13.0, 14.0),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onChooseRide,
            style: FilledButton.styleFrom(
              backgroundColor: RentalTimeTokens.white,
              foregroundColor: RentalTimeTokens.black,
              elevation: 4,
              shadowColor: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RentalTimeTokens.ctaRadius),
              ),
              minimumSize: Size(double.infinity, (w * 0.14).clamp(52.0, 56.0)),
            ),
            child: Text(
              'Choose a ride',
              style: TextStyle(
                fontSize: (w * 0.045).clamp(16.0, 17.0),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
