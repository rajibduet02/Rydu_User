import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/service_area_repository_impl.dart';
import '../../domain/service_area/service_area_models.dart';
import 'ride_booking_provider.dart';

/// Loads the service area when pickup or drop-off changes.
/// Watched by booking and map screens. Failures leave booking to the backend.
final serviceAreaSyncProvider = Provider<void>((ref) {
  Future<void> refresh() async {
    final booking = ref.read(rideBookingControllerProvider);
    final pickup = booking.pickupPlace;
    if (pickup == null || !pickup.hasCoordinates) {
      ref.read(serviceAreaDecisionProvider.notifier).state =
          const ServiceAreaDecision.cleared();
      return;
    }
    final ServiceAreaRepository repo;
    try {
      repo = ref.read(serviceAreaRepositoryProvider);
    } catch (_) {
      return;
    }
    final decision = await repo.decide(
      pickup: pickup,
      dropoff: booking.dropoffPlace,
    );
    ref.read(serviceAreaDecisionProvider.notifier).state = decision;
  }

  ref.listen(rideBookingControllerProvider, (previous, next) {
    final samePickup =
        previous?.pickupPlace?.latitude == next.pickupPlace?.latitude &&
        previous?.pickupPlace?.longitude == next.pickupPlace?.longitude &&
        previous?.pickupPlace?.placeId == next.pickupPlace?.placeId;
    final sameDropoff =
        previous?.dropoffPlace?.latitude == next.dropoffPlace?.latitude &&
        previous?.dropoffPlace?.longitude == next.dropoffPlace?.longitude &&
        previous?.dropoffPlace?.placeId == next.dropoffPlace?.placeId;
    if (samePickup && sameDropoff) return;
    unawaited(refresh());
  });

  final initial = ref.read(rideBookingControllerProvider);
  if (initial.pickupPlace != null) {
    unawaited(refresh());
  }
});
