import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../theme/home_screen_tokens.dart';

/// Persistent Home banner for an in-progress / searching booking.
class HomeActiveRideCard extends ConsumerWidget {
  const HomeActiveRideCard({
    super.key,
    this.showCancel = true,
  });

  final bool showCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rideBookingControllerProvider);
    if (!state.hasActiveBooking) return const SizedBox.shrink();

    final c = ref.read(rideBookingControllerProvider.notifier);
    final pickup = state.pickupSpotLabel.isNotEmpty
        ? state.pickupSpotLabel
        : (state.pickupLocation.isNotEmpty ? state.pickupLocation : 'Pickup');
    final driver = state.assignedDriver;
    final driverLine = driver == null
        ? null
        : [
            driver.name,
            driver.vehicleName ?? driver.plateNumber,
          ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' · ');

    return Material(
      color: HomeScreenTokens.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => c.resumeActiveRide(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HomeScreenTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: state.isSearchingForDriver
                          ? HomeScreenTokens.accent
                          : const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.activeRideStatusLabel,
                      style: const TextStyle(
                        color: HomeScreenTokens.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    state.serviceNameLabel,
                    style: const TextStyle(
                      color: HomeScreenTokens.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$pickup → ${state.destinationLabel}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: HomeScreenTokens.muted,
                  fontSize: 13,
                ),
              ),
              if (driverLine != null && driverLine.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  driverLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomeScreenTokens.muted,
                    fontSize: 12,
                  ),
                ),
              ],
              if (state.estimatedFare != null &&
                  state.estimatedFare!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  state.estimatedFare!,
                  style: const TextStyle(
                    color: HomeScreenTokens.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => c.resumeActiveRide(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HomeScreenTokens.white,
                        side: const BorderSide(color: HomeScreenTokens.border),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('View ride'),
                    ),
                  ),
                  if (showCancel && state.canCancelBooking) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: state.isCancelling
                            ? null
                            : () async {
                                final ok = await c.cancelActiveBooking();
                                if (!context.mounted) return;
                                if (!ok && state.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ref
                                                .read(
                                                  rideBookingControllerProvider,
                                                )
                                                .errorMessage ??
                                            'Could not cancel.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: state.isCancelling
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFFF87171),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
