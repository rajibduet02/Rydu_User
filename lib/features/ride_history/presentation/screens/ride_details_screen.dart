import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../../../ride_booking/presentation/models/airport_fare_presentation.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../providers/ride_history_provider.dart';
import '../ride_history_presentation.dart';
import '../theme/ride_history_tokens.dart';

class RideDetailsScreen extends ConsumerStatefulWidget {
  const RideDetailsScreen({super.key, this.rideId});

  final String? rideId;

  @override
  ConsumerState<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends ConsumerState<RideDetailsScreen> {
  bool _resumedActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
    });
  }

  void _bootstrap() {
    final id = widget.rideId?.trim();
    if (id == null || id.isEmpty) return;
    final ride = ref.read(rideBookingControllerProvider);
    if (ride.hasActiveBooking && ride.bookingId == id) {
      _resumedActive = true;
      ref.read(rideBookingControllerProvider.notifier).resumeActiveRide();
      return;
    }
    ref.read(rideHistoryControllerProvider.notifier).loadDetail(id);
  }

  void _goBack() {
    final router = ref.read(goRouterProvider);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(RouteNames.activity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(rideHistoryControllerProvider);
    final ride = ref.watch(rideBookingControllerProvider);
    final id = widget.rideId?.trim();
    if (_resumedActive ||
        (id != null &&
            ride.hasActiveBooking &&
            ride.bookingId == id)) {
      return const Scaffold(
        backgroundColor: RideHistoryTokens.background,
        body: AppLoader(),
      );
    }

    return Scaffold(
      backgroundColor: RideHistoryTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: RideHistoryTokens.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Ride details',
                      style: TextStyle(
                        color: RideHistoryTokens.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: history.isLoadingDetail
                  ? const AppLoader()
                  : history.detailError != null && history.detail == null
                  ? _DetailError(
                      message: history.detailError!,
                      onRetry: id == null
                          ? null
                          : () => ref
                                .read(rideHistoryControllerProvider.notifier)
                                .loadDetail(id),
                    )
                  : history.detail == null
                  ? const Center(
                      child: Text(
                        'Ride not found.',
                        style: TextStyle(color: RideHistoryTokens.muted),
                      ),
                    )
                  : _ReadOnlyRideDetail(booking: history.detail!),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: RideHistoryTokens.danger),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyRideDetail extends StatelessWidget {
  const _ReadOnlyRideDetail({required this.booking});

  final BookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final kind = RideHistoryPresentation.kind(booking.status);
    final chipColor = switch (kind) {
      RideHistoryStatusKind.completed => RideHistoryTokens.success,
      RideHistoryStatusKind.cancelled => RideHistoryTokens.danger,
      RideHistoryStatusKind.expired => RideHistoryTokens.warning,
      RideHistoryStatusKind.other => RideHistoryTokens.muted,
    };
    final timestamp = RideHistoryPresentation.preferredTimestamp(booking);
    final rows = <(String, String)>[
      (
        'Status',
        RideHistoryPresentation.statusLabel(booking.status),
      ),
      if (booking.bookingNumber != null)
        ('Booking number', booking.bookingNumber!),
      if (timestamp != null)
        ('Date', RideHistoryPresentation.formatTimestamp(timestamp)),
      ('Pickup', RideHistoryPresentation.pickupLabel(booking)),
      ('Destination', RideHistoryPresentation.dropoffLabel(booking)),
      if (RideHistoryPresentation.serviceLabel(booking) != null)
        ('Service', RideHistoryPresentation.serviceLabel(booking)!),
      if (booking.formattedFare != null && !booking.hasAirportSurcharge)
        ('Fare', booking.formattedFare!),
      if (booking.hasAirportSurcharge) ...[
        (
          AirportFarePresentation.tripFareLabel,
          AirportFarePresentation.money(
            booking.currency,
            booking.displayTripFare,
          ),
        ),
        (
          AirportFarePresentation.feeLabel(booking.airport),
          AirportFarePresentation.money(
            booking.currency,
            booking.airportFee ?? 0,
          ),
        ),
        (
          AirportFarePresentation.totalLabel,
          AirportFarePresentation.money(
            booking.currency,
            booking.finalFare ?? 0,
          ),
        ),
      ],
      if (booking.paymentMethodName != null || booking.paymentMethodCode != null)
        (
          'Payment',
          [
            booking.paymentMethodName ?? booking.paymentMethodCode,
            if (booking.paymentStatus != null) booking.paymentStatus,
          ].whereType<String>().join(' · '),
        ),
      if (booking.driver?.name != null) ('Driver', booking.driver!.name),
      if (booking.vehicle?.displayLabel != null ||
          booking.driver?.vehicleName != null)
        (
          'Vehicle',
          booking.vehicle?.displayLabel ??
              [
                booking.driver?.vehicleName,
                booking.vehicle?.plateNumber ?? booking.driver?.plateNumber,
              ].whereType<String>().where((e) => e.trim().isNotEmpty).join(' · '),
        ),
      if (RideHistoryPresentation.distanceDurationLabel(booking) != null)
        (
          'Route',
          RideHistoryPresentation.distanceDurationLabel(booking)!,
        ),
      if (booking.cancellationReason != null &&
          booking.cancellationReason!.trim().isNotEmpty)
        ('Cancellation reason', booking.cancellationReason!.trim()),
      if (booking.recordingAvailable == true)
        ('Recording', 'Recording available'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        if (kind == RideHistoryStatusKind.expired)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              RideHistoryPresentation.expiredCopy(),
              style: const TextStyle(
                color: RideHistoryTokens.muted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RideHistoryTokens.sheet,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: RideHistoryTokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  RideHistoryPresentation.statusLabel(booking.status),
                  style: TextStyle(
                    color: chipColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                Text(
                  rows[i].$1,
                  style: const TextStyle(
                    color: RideHistoryTokens.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rows[i].$2,
                  style: const TextStyle(
                    color: RideHistoryTokens.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
