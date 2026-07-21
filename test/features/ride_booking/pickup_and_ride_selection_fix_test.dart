import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/location/location_service.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/presentation/models/ride_vehicle_option.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_controller.dart';

void main() {
  group('Promotion parsing', () {
    test('parses promotion object to title only', () {
      final promo = RidePlanningParsers.promotion({
        'id': '11111111-2222-3333-4444-555555555555',
        'title': '40% off evenings',
        'discountType': 'percentage',
        'discountValue': 40,
      });
      expect(promo, isNotNull);
      expect(promo!.displayTitle, '40% off evenings');
      expect(promo.displayTitle!.contains('11111111'), isFalse);
    });

    test('rejects map dump strings', () {
      final promo = RidePlanningParsers.promotion('{id: abc, title: Promo}');
      expect(promo, isNull);
    });

    test('parses legacy string promotion', () {
      final promo = RidePlanningParsers.promotion('Flash sale');
      expect(promo?.displayTitle, 'Flash sale');
    });

    test('null promotion is safe', () {
      expect(RidePlanningParsers.promotion(null), isNull);
    });

    test('service quote stores typed promotion', () {
      final quote = RidePlanningParsers.serviceQuote({
        'serviceCategoryId': 'svc1',
        'serviceName': 'CNG',
        'capacity': 3,
        'distanceKm': 5,
        'durationMin': 12,
        'originalFare': 200,
        'discountAmount': 40,
        'finalFare': 160,
        'currency': 'BDT',
        'promotion': {'id': 'promo-uuid', 'title': 'Save more'},
      });
      expect(quote, isNotNull);
      expect(quote!.promotion?.displayTitle, 'Save more');
      final option = rideOptionFromQuote(quote);
      expect(option.promotion, 'Save more');
      expect(option.promotion!.contains('promo-uuid'), isFalse);
    });
  });

  group('Pickup resolution rules', () {
    const gpsPickup = PlaceEntity(
      placeId: '',
      label: 'Road 2, Dhanmondi',
      address: 'Dhanmondi, Dhaka',
      latitude: 23.75,
      longitude: 90.38,
    );
    const dropoff = PlaceEntity(
      placeId: 'd1',
      label: 'Mirpur',
      address: 'Dhaka',
      latitude: 23.8,
      longitude: 90.4,
    );

    test('1. current GPS pickup is resolved without placeId', () {
      expect(gpsPickup.placeId, isEmpty);
      expect(gpsPickup.hasCoordinates, isTrue);
      const state = RideBookingState(
        pickupPlace: gpsPickup,
        pickupLocation: 'Road 2, Dhanmondi',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
      );
      expect(state.hasResolvedPickup, isTrue);
    });

    test('2. reverse-geocoded GPS updates pickup text via state label', () {
      const state = RideBookingState(
        pickupPlace: gpsPickup,
        pickupLocation: 'Road 2, Dhanmondi',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
      );
      expect(state.pickupLocation, 'Road 2, Dhanmondi');
      expect(state.pickupLocation, isNot(equals('Choose pickup location')));
    });

    test('3. destination selection does not clear pickup', () {
      final state = const RideBookingState(
        pickupPlace: gpsPickup,
        pickupLocation: 'Road 2, Dhanmondi',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
      ).copyWith(dropoffPlace: dropoff, destinationQuery: 'Mirpur');
      expect(state.hasResolvedPickup, isTrue);
      expect(state.hasResolvedDestination, isTrue);
      expect(state.pickupLocation, 'Road 2, Dhanmondi');
      expect(state.pickupPlace?.latitude, 23.75);
    });

    test('4. programmatic pickup text matching label keeps coordinates', () {
      var state = const RideBookingState(
        pickupPlace: gpsPickup,
        pickupLocation: 'Road 2, Dhanmondi',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
      );
      final sameLabel = state.pickupPlace!.label.trim();
      final diverged = state.hasResolvedPickup && sameLabel != sameLabel;
      expect(diverged, isFalse);
      state = state.copyWith(pickupLocation: sameLabel);
      expect(state.hasResolvedPickup, isTrue);
      expect(state.pickupPlace?.longitude, 90.38);
    });

    test('5. user editing pickup invalidates old coordinates', () {
      final state =
          const RideBookingState(
            pickupPlace: gpsPickup,
            pickupLocation: 'Road 2, Dhanmondi',
            pickupSource: PickupSource.currentLocation,
            isPickupResolved: true,
          ).copyWith(
            pickupLocation: 'Banani typed',
            clearPickupPlace: true,
            isPickupResolved: false,
            pickupSource: PickupSource.none,
          );
      expect(state.hasResolvedPickup, isFalse);
      expect(state.pickupPlace, isNull);
    });

    test('6. use current location preserves destination in copyWith', () {
      final before = const RideBookingState(
        dropoffPlace: dropoff,
        destinationQuery: 'Mirpur',
      );
      final after = before.copyWith(
        pickupPlace: gpsPickup,
        pickupLocation: gpsPickup.label,
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
        activeSearchField: ActiveSearchField.pickup,
        predictions: const [],
      );
      expect(after.hasResolvedDestination, isTrue);
      expect(after.dropoffPlace?.label, 'Mirpur');
      expect(after.destinationQuery, 'Mirpur');
    });

    test(
      '7. use current location with destination enables route preview gate',
      () {
        const both = RideBookingState(
          pickupPlace: gpsPickup,
          pickupLocation: 'Road 2, Dhanmondi',
          pickupSource: PickupSource.currentLocation,
          isPickupResolved: true,
          dropoffPlace: dropoff,
          destinationQuery: 'Mirpur',
        );
        expect(both.hasResolvedPickup && both.hasResolvedDestination, isTrue);
      },
    );

    test('8. manual pickup selection resolves pickup', () {
      const manual = PlaceEntity(
        placeId: 'p1',
        label: 'Banasree',
        address: 'Dhaka',
        latitude: 23.76,
        longitude: 90.42,
      );
      const state = RideBookingState(
        pickupPlace: manual,
        pickupLocation: 'Banasree',
        pickupSource: PickupSource.manualSelection,
        isPickupResolved: true,
      );
      expect(state.hasResolvedPickup, isTrue);
      expect(state.pickupSource, PickupSource.manualSelection);
    });

    test('9. route preview blocked when pickup missing', () {
      const state = RideBookingState(
        dropoffPlace: dropoff,
        destinationQuery: 'Mirpur',
      );
      expect(state.hasResolvedPickup, isFalse);
      expect(state.hasResolvedDestination, isTrue);
      expect(
        state.unresolvedLocationsMessage(),
        'Please select a pickup location.',
      );
    });

    test('10. pickup-specific validation message', () {
      const state = RideBookingState(
        dropoffPlace: dropoff,
        destinationQuery: 'Mirpur',
      );
      expect(
        state.unresolvedLocationsMessage(),
        'Please select a pickup location.',
      );
    });

    test('11. destination-specific validation message', () {
      const state = RideBookingState(
        pickupPlace: gpsPickup,
        pickupLocation: 'Road 2, Dhanmondi',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
      );
      expect(
        state.unresolvedLocationsMessage(),
        'Please select a destination from the suggestions.',
      );
    });

    test('12. both resolved yields empty validation message', () {
      const state = RideBookingState(
        pickupPlace: gpsPickup,
        pickupLocation: 'Road 2, Dhanmondi',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
        dropoffPlace: dropoff,
        destinationQuery: 'Mirpur',
      );
      expect(state.unresolvedLocationsMessage(), isEmpty);
    });

    test('13. permission denied allows manual pickup search state', () {
      const state = RideBookingState(
        phase: RidePlanningPhase.permissionDenied,
        permissionStatus: AppLocationPermissionStatus.denied,
        errorMessage:
            'Location permission is required for automatic pickup. You can search pickup manually.',
      );
      expect(state.hasResolvedPickup, isFalse);
      expect(state.phase, RidePlanningPhase.permissionDenied);
      expect(state.activeSearchField, ActiveSearchField.none);
    });

    test('14. reverse-geocode failure can keep GPS coordinate label', () {
      const coordLabel = PlaceEntity(
        placeId: '',
        label: 'Current location',
        address: '23.75000, 90.38000',
        latitude: 23.75,
        longitude: 90.38,
      );
      const state = RideBookingState(
        pickupPlace: coordLabel,
        pickupLocation: 'Current location',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
      );
      expect(state.hasResolvedPickup, isTrue);
      expect(coordLabel.placeId, isEmpty);
    });

    test('15. empty current-location placeId does not make pickup invalid', () {
      const state = RideBookingState(
        pickupPlace: gpsPickup,
        pickupLocation: 'Road 2, Dhanmondi',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: true,
      );
      expect(gpsPickup.placeId.isEmpty, isTrue);
      expect(state.hasResolvedPickup, isTrue);
    });

    test('typed text without suggestion uses suggestions message', () {
      const state = RideBookingState(
        pickupLocation: 'Banani',
        pickupSource: PickupSource.none,
        isPickupResolved: false,
        destinationQuery: 'Mirpur',
      );
      expect(
        state.unresolvedLocationsMessage(),
        'Select a location from the suggestions.',
      );
    });

    test('lost isPickupResolved flag still resolves for currentLocation', () {
      const state = RideBookingState(
        pickupPlace: gpsPickup,
        pickupLocation: 'Road 2, Dhanmondi',
        pickupSource: PickupSource.currentLocation,
        isPickupResolved: false,
      );
      expect(state.hasResolvedPickup, isTrue);
    });

    test('both missing locations message', () {
      const state = RideBookingState();
      expect(
        state.unresolvedLocationsMessage(),
        'Please select pickup and destination locations.',
      );
    });
  });

  group('Promotion banner overflow safety', () {
    testWidgets('long promotion title ellipsizes in Flexible row', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, size: 24),
                  const Spacer(),
                  Flexible(
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '{id: 11111111-2222-3333-4444-555555555555, title: Extremely long promotion text that would overflow}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
