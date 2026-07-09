import 'package:flutter/material.dart';

import '../models/suggested_location.dart';
import '../theme/ride_booking_tokens.dart';

class SuggestedLocationTile extends StatelessWidget {
  const SuggestedLocationTile({
    super.key,
    required this.location,
    required this.onTap,
  });

  final SuggestedLocation location;
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
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RideBookingTokens.tileRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  color: RideBookingTokens.muted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            location.name,
                            style: const TextStyle(
                              color: RideBookingTokens.titleWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          location.distance,
                          style: const TextStyle(
                            color: RideBookingTokens.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.address,
                      style: const TextStyle(
                        color: RideBookingTokens.muted,
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
