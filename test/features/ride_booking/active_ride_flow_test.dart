import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/pickup_spot_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_controller.dart';

void main() {
  group('ridePhaseFromBookingStatus', () {
    test('searching keeps searching phase', () {
      expect(
        ridePhaseFromBookingStatus('searching'),
        RidePlanningPhase.bookingSearching,
      );
    });

    test('accepted transitions to accepted', () {
      expect(
        ridePhaseFromBookingStatus('accepted'),
        RidePlanningPhase.driverAccepted,
      );
    });

    test('driver_en_route updates phase', () {
      expect(
        ridePhaseFromBookingStatus('driver_en_route'),
        RidePlanningPhase.driverEnRoute,
      );
    });

    test('arrived updates phase', () {
      expect(
        ridePhaseFromBookingStatus('arrived'),
        RidePlanningPhase.driverArrived,
      );
    });

    test('in_progress updates phase', () {
      expect(
        ridePhaseFromBookingStatus('in_progress'),
        RidePlanningPhase.rideInProgress,
      );
    });

    test('completed updates phase', () {
      expect(
        ridePhaseFromBookingStatus('completed'),
        RidePlanningPhase.completed,
      );
    });

    test('expired updates no-driver/expired state', () {
      expect(ridePhaseFromBookingStatus('expired'), RidePlanningPhase.expired);
    });

    test('cancelled updates cancellation state', () {
      expect(
        ridePhaseFromBookingStatus('cancelled'),
        RidePlanningPhase.cancelled,
      );
    });

    test('offered stays on finding-driver phase family', () {
      expect(
        ridePhaseFromBookingStatus('offered'),
        RidePlanningPhase.bookingOffered,
      );
    });

    test('no_drivers maps correctly', () {
      expect(
        ridePhaseFromBookingStatus('no_drivers'),
        RidePlanningPhase.noDrivers,
      );
    });
  });

  group('RideBookingState active-ride helpers', () {
    test('searching and offered are searching phases', () {
      expect(
        const RideBookingState(
          phase: RidePlanningPhase.bookingSearching,
        ).isSearchingForDriver,
        isTrue,
      );
      expect(
        const RideBookingState(
          phase: RidePlanningPhase.bookingOffered,
        ).isSearchingForDriver,
        isTrue,
      );
    });

    test('accepted and en_route are assigned phases', () {
      expect(
        const RideBookingState(
          phase: RidePlanningPhase.driverAccepted,
        ).isAssignedRidePhase,
        isTrue,
      );
      expect(
        const RideBookingState(
          phase: RidePlanningPhase.driverEnRoute,
        ).isAssignedRidePhase,
        isTrue,
      );
    });

    test('quote failure state has no hardcoded fare', () {
      const state = RideBookingState(
        rideOptions: [],
        estimatedFare: null,
        phase: RidePlanningPhase.error,
        errorMessage: 'Could not load ride quotes.',
      );
      expect(state.rideOptions, isEmpty);
      expect(state.estimatedFare, isNull);
      expect(state.errorMessage, isNotNull);
    });

    test('default state has no hardcoded pickup or fare', () {
      const state = RideBookingState();
      expect(state.pickupLocation, isEmpty);
      expect(state.estimatedFare, isNull);
      expect(state.paymentMethodCode, isEmpty);
    });

    test('pickup spot label falls back to selected pickup', () {
      const state = RideBookingState(
        pickupLocation: 'Selected Road',
        pickupPlace: PlaceEntity(
          placeId: 'p',
          label: 'Selected Road',
          address: 'Dhaka',
          latitude: 23.8,
          longitude: 90.4,
        ),
        pickupSpots: [],
      );
      expect(state.pickupSpotLabel, 'Selected Road');
    });

    test('pickup spots use API result labels', () {
      const state = RideBookingState(
        pickupSpots: [
          PickupSpotEntity(
            index: 0,
            label: 'Gate A',
            address: 'Mall Gate A',
            source: 'managed',
          ),
        ],
        selectedPickupSpotIndex: 0,
      );
      expect(state.pickupSpotLabel, 'Gate A');
    });

    test('duplicate navigation key prevents repeat nav', () {
      const state = RideBookingState(
        bookingId: 'b1',
        phase: RidePlanningPhase.driverAccepted,
        lastNavigatedPhaseKey: 'b1:driverAccepted',
      );
      expect(state.lastNavigatedPhaseKey, 'b1:driverAccepted');
    });
  });

  group('driver location parsing', () {
    test('valid location for booking is parsed', () {
      final location = RidePlanningParsers.driverLocation({
        'driverId': 'd1',
        'bookingId': 'b1',
        'latitude': 23.8103,
        'longitude': 90.4125,
        'heading': 180,
        'timestamp': '2026-07-10T12:00:00.000Z',
      });
      expect(location, isNotNull);
      expect(location!.bookingId, 'b1');
      expect(location.heading, 180);
    });

    test('invalid coordinates are rejected by parser', () {
      final location = RidePlanningParsers.driverLocation({
        'driverId': 'd1',
        'bookingId': 'b1',
        'latitude': null,
        'longitude': 90.4,
      });
      expect(location, isNull);
    });

    test('booking parse includes assigned driver', () {
      final booking = RidePlanningParsers.booking({
        'id': 'b1',
        'status': 'accepted',
        'bookingNumber': 'RYD-1',
        'currency': 'BDT',
        'finalFare': 120.5,
        'driver': {
          'id': 'd1',
          'name': 'Driver One',
          'plateNumber': 'DH-123',
          'etaMinutes': 3,
        },
        'pickup': {
          'address': 'Pickup Rd',
          'latitude': 23.81,
          'longitude': 90.41,
        },
      });
      expect(booking, isNotNull);
      expect(booking!.driver?.name, 'Driver One');
      expect(booking.formattedFare, 'BDT 120.50');
      expect(booking.isActive, isTrue);
    });
  });

  group('FindingDriverScreen production guards', () {
    test('does not contain timer-based navigation', () {
      final file = File(
        'lib/features/ride_tracking/presentation/screens/finding_driver_screen.dart',
      );
      final source = file.readAsStringSync();
      expect(source.contains('Future.delayed'), isFalse);
      expect(source.contains('navigateToDriverFound'), isFalse);
      expect(source.contains('ActiveRideMap'), isTrue);
      expect(source.contains('cancelActiveBooking'), isTrue);
      expect(source.contains('minimizeActiveRide'), isTrue);
      // Elapsed status may use Timer.periodic — must not fake-navigate.
      expect(source.contains('pushReplacement'), isTrue);
    });

    test('finding driver defaults are empty not hardcoded', () {
      final file = File(
        'lib/features/ride_tracking/presentation/providers/finding_driver_controller.dart',
      );
      final source = file.readAsStringSync();
      expect(source.contains('35 Road No. 2'), isFalse);
      expect(source.contains('BDT 155.84'), isFalse);
      expect(source.contains('Waffle Hut'), isFalse);
    });

    test('driver found defaults are empty not hardcoded', () {
      final file = File(
        'lib/features/ride_tracking/presentation/providers/driver_found_controller.dart',
      );
      final source = file.readAsStringSync();
      expect(source.contains('MOHAMMAD MOHIDUL ISLAM'), isFalse);
      expect(source.contains('DHM-LA-63-525'), isFalse);
      expect(source.contains('BDT 155.84'), isFalse);
      expect(source.contains('cancelActiveBooking'), isTrue);
    });
  });

  group('payment method selection', () {
    test('uses backend method code when present', () {
      const methods = [
        PaymentMethodEntity(code: 'cash', label: 'Cash', isDefault: true),
        PaymentMethodEntity(code: 'bkash', label: 'bKash'),
      ];
      final selected = methods.firstWhere((m) => m.isDefault);
      expect(selected.code, 'cash');
      expect(methods.map((m) => m.code), containsAll(['cash', 'bkash']));
    });
  });
}
