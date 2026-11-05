import 'package:flutter/material.dart';

import '../../../ride_booking/domain/entities/meter_payment_entities.dart';
import '../../../ride_booking/domain/entities/passenger_meter_entities.dart';
import '../../../ride_booking/presentation/theme/ride_booking_tokens.dart';

/// Compact live Soft Meter preview. Never a payment control.
class SoftMeterPanel extends StatelessWidget {
  const SoftMeterPanel({
    super.key,
    required this.meter,
  });

  final PassengerMeterSnapshot meter;

  @override
  Widget build(BuildContext context) {
    final paused = meter.isPausedDisplay;
    final fare = meter.formattedProvisionalFare;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RideBookingTokens.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: paused ? const Color(0xFFF59E0B) : RideBookingTokens.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paused ? 'Soft Meter Paused' : 'Soft Meter',
            style: const TextStyle(
              color: RideBookingTokens.titleWhite,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          if (paused) ...[
            const SizedBox(height: 6),
            const Text(
              'Distance and time charges are suspended.',
              style: TextStyle(
                color: RideBookingTokens.muted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 6),
          const Text(
            SoftMeterPaymentCopy.duringTrip,
            style: TextStyle(
              color: RideBookingTokens.muted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Stopped-time charges apply only when the vehicle is confirmed stationary.',
            style: TextStyle(
              color: RideBookingTokens.muted,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (fare != null) ...[
            const SizedBox(height: 10),
            Text(
              fare,
              style: const TextStyle(
                color: RideBookingTokens.titleWhite,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
          if (meter.statusLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            _MeterRow(label: 'Meter status', value: meter.statusLabel),
          ],
          if (meter.formattedFlagDrop != null)
            _MeterRow(
              label: 'Initial flag drop',
              value: meter.formattedFlagDrop!,
            ),
          if (meter.formattedDistanceMiles != null)
            _MeterRow(
              label: 'Distance traveled',
              value: meter.formattedDistanceMiles!,
            ),
          if (meter.formattedDistanceCharge != null)
            _MeterRow(
              label: 'Distance charge',
              value: meter.formattedDistanceCharge!,
            ),
          if (meter.formattedEligibleStoppedTime != null)
            _MeterRow(
              label: 'Eligible stopped time',
              value: meter.formattedEligibleStoppedTime!,
            ),
          if (meter.formattedWaitingCharge != null)
            _MeterRow(
              label: 'Stopped-time charge',
              value: meter.formattedWaitingCharge!,
            ),
          if (meter.formattedBilledStoppedMinutes != null)
            _MeterRow(
              label: 'Billed stopped minutes',
              value: meter.formattedBilledStoppedMinutes!,
            ),
          if (meter.formattedUnbilledRemainder != null)
            _MeterRow(
              label: 'Unbilled remainder',
              value: meter.formattedUnbilledRemainder!,
            ),
          if (meter.formattedTripElapsed != null)
            _MeterRow(
              label: 'Trip time',
              value: meter.formattedTripElapsed!,
            ),
          if (meter.formattedChargeableElapsed != null)
            _MeterRow(
              label: 'Chargeable time',
              value: meter.formattedChargeableElapsed!,
            ),
          if (meter.formattedPauseDuration != null)
            _MeterRow(
              label: 'Pause duration',
              value: meter.formattedPauseDuration!,
            ),
          if (meter.isReviewRequiredDisplay) ...[
            const SizedBox(height: 10),
            const Text(
              'This meter is marked for review. It is not a new charge.',
              style: TextStyle(
                color: Color(0xFFF59E0B),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MeterRow extends StatelessWidget {
  const _MeterRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: RideBookingTokens.muted,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: RideBookingTokens.titleWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
