import 'package:flutter/material.dart';

import '../theme/ride_booking_tokens.dart';

class PickupLocationCard extends StatelessWidget {
  const PickupLocationCard({
    super.key,
    required this.name,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RideBookingTokens.cardFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? RideBookingTokens.accent
                  : RideBookingTokens.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: RideBookingTokens.titleWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(
                  color: RideBookingTokens.muted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
