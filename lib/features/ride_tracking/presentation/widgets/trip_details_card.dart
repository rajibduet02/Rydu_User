import 'package:flutter/material.dart';

import '../../../ride_booking/presentation/models/suggested_location.dart';
import '../../../ride_booking/presentation/theme/ride_booking_tokens.dart';

class TripDetailsCard extends StatelessWidget {
  const TripDetailsCard({
    super.key,
    required this.pickupSpotName,
    required this.destination,
    required this.rideId,
    required this.paymentMethod,
    required this.estimatedFare,
    required this.onShareTrip,
    required this.onCancelRide,
  });

  final String pickupSpotName;
  final SuggestedLocation? destination;
  final String rideId;
  final String paymentMethod;
  final String estimatedFare;
  final VoidCallback onShareTrip;
  final VoidCallback onCancelRide;

  @override
  Widget build(BuildContext context) {
    final destName = destination?.name ?? 'Bashir Super Market';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RideBookingTokens.cardFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RideBookingTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ride details',
                style: TextStyle(
                  color: RideBookingTokens.titleWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _TripRow(
                leading: _dotCircle(),
                title: 'Meet at the pickup spot for $pickupSpotName',
                subtitle: pickupSpotName,
              ),
              const SizedBox(height: 16),
              _TripRow(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: RideBookingTokens.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: RideBookingTokens.muted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                title: destName,
                subtitle: '1 Person (Add)',
              ),
              const SizedBox(height: 16),
              _TripRow(
                leading: const Text('👤', style: TextStyle(fontSize: 20)),
                title: rideId,
                subtitle: 'Use $paymentMethod $estimatedFare',
                trailing: const Text(
                  'Switch',
                  style: TextStyle(
                    color: RideBookingTokens.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _TripRow(
                leading: const Text('📱', style: TextStyle(fontSize: 20)),
                title: 'Share trip status',
                trailing: TextButton(
                  onPressed: onShareTrip,
                  child: const Text(
                    'Share',
                    style: TextStyle(
                      color: RideBookingTokens.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onCancelRide,
          child: const Text(
            'Cancel ride',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  static Widget _dotCircle() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: RideBookingTokens.accent, width: 2),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: RideBookingTokens.accent,
        ),
      ),
    );
  }
}

class _TripRow extends StatelessWidget {
  const _TripRow({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: RideBookingTokens.titleWhite,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: RideBookingTokens.muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
