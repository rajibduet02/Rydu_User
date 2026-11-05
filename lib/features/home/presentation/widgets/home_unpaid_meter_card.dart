import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ride_booking/domain/entities/meter_payment_entities.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../theme/home_screen_tokens.dart';

class HomeUnpaidMeterCard extends ConsumerWidget {
  const HomeUnpaidMeterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rideBookingControllerProvider);
    if (!state.shouldShowUnpaidMeterReminder) return const SizedBox.shrink();
    final payment = state.unpaidMeterPayment ?? state.meterPayment;
    if (payment == null) return const SizedBox.shrink();
    final c = ref.read(rideBookingControllerProvider.notifier);
    final fare = payment.formattedFinalFare;

    return Material(
      color: HomeScreenTokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => c.openMeterPayment(bookingId: payment.bookingId),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Pending',
                style: TextStyle(
                  color: HomeScreenTokens.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                fare == null
                    ? SoftMeterPaymentCopy.preparing
                    : '${SoftMeterPaymentCopy.afterTrip} · $fare',
                style: const TextStyle(
                  color: HomeScreenTokens.muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                SoftMeterPaymentCopy.testMode,
                style: TextStyle(
                  color: HomeScreenTokens.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: state.isStartingMeterCheckout
                          ? null
                          : () => c.startMeterCheckout(
                              bookingId: payment.bookingId,
                            ),
                      child: Text(
                        state.isStartingMeterCheckout ? 'Opening…' : 'Pay Now',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => c.openMeterPayment(
                        bookingId: payment.bookingId,
                      ),
                      child: const Text('Ride details'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
