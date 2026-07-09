import 'package:flutter/material.dart';

import '../theme/ride_booking_tokens.dart';

class RideBookingActionTile extends StatelessWidget {
  const RideBookingActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RideBookingTokens.tileRadius),
        splashColor: RideBookingTokens.tileHover.withValues(alpha: 0.5),
        highlightColor: RideBookingTokens.tileHover.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: RideBookingTokens.muted, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: RideBookingTokens.titleWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
