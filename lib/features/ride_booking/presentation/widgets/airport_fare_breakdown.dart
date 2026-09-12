import 'package:flutter/material.dart';

import '../models/airport_fare_presentation.dart';
import '../theme/ride_booking_tokens.dart';

/// Transparent surcharge summary. Hidden for regular trips (no airport fee).
class AirportFareBreakdown extends StatelessWidget {
  const AirportFareBreakdown({super.key, required this.data});

  final AirportFareBreakdownData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: RideBookingTokens.cardFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: RideBookingTokens.border),
      ),
      child: Column(
        children: [
          _row(data.tripFareLabel, data.tripFareAmount, emphasized: false),
          const SizedBox(height: 8),
          _row(data.airportFeeLabel, data.airportFeeAmount, emphasized: false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: RideBookingTokens.border),
          ),
          _row(data.totalLabel, data.totalAmount, emphasized: true),
        ],
      ),
    );
  }

  Widget _row(String label, String amount, {required bool emphasized}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasized
                  ? RideBookingTokens.titleWhite
                  : RideBookingTokens.muted,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              fontSize: emphasized ? 15 : 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: TextStyle(
            color: RideBookingTokens.titleWhite,
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            fontSize: emphasized ? 15 : 13,
          ),
        ),
      ],
    );
  }
}
