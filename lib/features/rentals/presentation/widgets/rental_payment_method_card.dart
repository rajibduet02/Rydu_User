import 'package:flutter/material.dart';

import '../theme/rental_ride_tokens.dart';

class RentalPaymentMethodCard extends StatelessWidget {
  const RentalPaymentMethodCard({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.04).clamp(15.0, 16.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RentalRideTokens.cardRadius),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RentalRideTokens.cardSelected,
            borderRadius: BorderRadius.circular(RentalRideTokens.cardRadius),
            border: Border.all(color: RentalRideTokens.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F6BFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: RentalRideTokens.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: RentalRideTokens.muted,
                size: (w * 0.06).clamp(22.0, 26.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
