import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/home/presentation/providers/home_controller.dart';
import 'package:rydu_user/features/ride_booking/data/utils/booking_create_request.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/constants/passenger_service_categories.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/presentation/models/ride_vehicle_option.dart';
import 'package:rydu_user/features/ride_booking/presentation/widgets/ride_option_card.dart';
import 'package:rydu_user/features/services/data/datasources/services_local_datasource.dart';

void main() {
  const route = {
    'distanceMeters': 1000,
    'durationSeconds': 300,
    'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    'routeBounds': {
      'northeast': {'lat': 1.0, 'lng': 1.0},
      'southwest': {'lat': 0.0, 'lng': 0.0},
    },
  };

  Map<String, dynamic> quoteJson({
    required String id,
    required String code,
    required String name,
    required String iconKey,
    required int capacity,
    String? displayName,
  }) {
    return {
      'serviceCategoryId': id,
      'serviceCode': code,
      'serviceName': name,
      'displayName': ?displayName,
      'iconKey': iconKey,
      'description': '$name ride',
      'capacity': capacity,
      'distanceKm': 4.2,
      'durationMin': 12,
      'driverEtaMinutes': 5,
      'originalFare': 300,
      'discountAmount': 0,
      'finalFare': 250,
      'currency': 'BDT',
    };
  }

  RideOptionEntity optionFor(Map<String, dynamic> json) {
    final quote = RidePlanningParsers.serviceQuote(json);
    expect(quote, isNotNull);
    return rideOptionFromQuote(quote!);
  }

  group('new service categories', () {
    final cases = [
      (
        code: 'ECONOMY',
        name: 'Economy Sedan',
        iconKey: 'economy',
        capacity: 3,
        emoji: '🚘',
      ),
      (
        code: 'EXECUTIVE',
        name: 'Executive Sedan',
        iconKey: 'executive',
        capacity: 3,
        emoji: '✨',
      ),
      (code: 'SUV', name: 'SUV', iconKey: 'suv', capacity: 6, emoji: '🚙'),
      (
        code: 'VAN',
        name: 'Passenger Van',
        iconKey: 'van',
        capacity: 8,
        emoji: '🚐',
      ),
      (
        code: 'MINIVAN',
        name: 'Mini-Van',
        iconKey: 'minivan',
        capacity: 5,
        emoji: '🚕',
      ),
      (
        code: 'ADA',
        name: 'ADA Accessible',
        iconKey: 'ada',
        capacity: 4,
        emoji: '♿',
      ),
    ];

    for (final item in cases) {
      test('${item.code} quote parses and renders', () {
        final id = 'category-${item.code.toLowerCase()}';
        final option = optionFor(
          quoteJson(
            id: id,
            code: item.code,
            name: item.name,
            iconKey: item.iconKey,
            capacity: item.capacity,
          ),
        );
        expect(option.id, id);
        expect(option.name, item.name);
        expect(option.serviceCode, item.code);
        expect(option.capacity, '${item.capacity}');
        expect(option.price, 'BDT 250.00');
        expect(option.currency, 'BDT');
        expect(option.iconEmoji, item.emoji);
        expect(option.time, '5 min');
      });
    }

    test('preserves backend quote order', () {
      final quote = RidePlanningParsers.bookingQuote({
        'route': route,
        'quotes': [
          for (final item in cases)
            quoteJson(
              id: 'id-${item.code}',
              code: item.code,
              name: item.name,
              iconKey: item.iconKey,
              capacity: item.capacity,
            ),
        ],
      });
      expect(
        quote!.quotes.map((q) => q.serviceCode).toList(),
        cases.map((item) => item.code).toList(),
      );
    });

    test('displayName wins over serviceName and is optional', () {
      final withDisplay = RidePlanningParsers.serviceQuote(
        quoteJson(
          id: 'exec-1',
          code: 'EXECUTIVE',
          name: 'EXECUTIVE',
          displayName: 'Executive Sedan',
          iconKey: 'executive',
          capacity: 3,
        ),
      );
      expect(withDisplay!.serviceName, 'Executive Sedan');

      final legacyNameOnly = RidePlanningParsers.serviceQuote({
        'serviceCategoryId': 'old-ride',
        'serviceCode': 'RIDE',
        'serviceName': 'Ride',
        'capacity': 4,
        'finalFare': 100,
        'currency': 'BDT',
      });
      expect(legacyNameOnly!.serviceName, 'Ride');
      expect(legacyNameOnly.serviceCode, 'RIDE');
    });

    test('selected quote id is the booking serviceCategoryId', () {
      final option = optionFor(
        quoteJson(
          id: 'backend-uuid-economy',
          code: 'ECONOMY',
          name: 'Economy Sedan',
          iconKey: 'economy',
          capacity: 3,
        ),
      );
      final body = BookingCreateRequest.body(
        serviceCategoryId: option.id,
        pickup: const LatLngWaypoint(latitude: 23.8, longitude: 90.4),
        dropoff: const LatLngWaypoint(latitude: 23.7, longitude: 90.3),
        paymentMethodCode: 'card',
      );
      expect(body['serviceCategoryId'], 'backend-uuid-economy');
      expect(option.id, 'backend-uuid-economy');
    });

    test('unknown category uses the generic car visual', () {
      final option = optionFor(
        quoteJson(
          id: 'future-1',
          code: 'SHUTTLE',
          name: 'Shuttle',
          iconKey: 'shuttle',
          capacity: 10,
        ),
      );
      expect(option.iconEmoji, '🚗');
      expect(option.name, 'Shuttle');
    });

    test('legacy bike and cng quotes still parse and render', () {
      final bike = optionFor({
        'serviceCategoryId': 'legacy-bike',
        'serviceCode': 'BIKE',
        'serviceName': 'Bike',
        'iconKey': 'bike',
        'capacity': 1,
        'finalFare': 80,
        'currency': 'BDT',
      });
      final cng = optionFor({
        'serviceCategoryId': 'legacy-cng',
        'serviceCode': 'CNG',
        'name': 'CNG',
        'iconKey': 'cng',
        'capacity': 3,
        'finalFare': 120,
        'currency': 'BDT',
      });
      expect(bike.name, 'Bike');
      expect(bike.iconEmoji, '🏍️');
      expect(cng.name, 'CNG');
      expect(cng.iconEmoji, '⚡');
    });

    test('historical booking still displays stored service names', () {
      final booking = RidePlanningParsers.booking({
        'id': 'booking-1',
        'status': 'completed',
        'serviceCategoryId': 'legacy-premium',
        'serviceCode': 'PREMIUM',
        'serviceName': 'Premium',
      });
      expect(booking!.serviceName, 'Premium');
      expect(booking.serviceCode, 'PREMIUM');
      expect(booking.serviceCategoryId, 'legacy-premium');
    });

    test('bus is not injected into a quote response', () {
      final quote = RidePlanningParsers.bookingQuote({
        'route': route,
        'quotes': [
          quoteJson(
            id: 'eco-1',
            code: 'ECONOMY',
            name: 'Economy Sedan',
            iconKey: 'economy',
            capacity: 3,
          ),
        ],
      });
      expect(quote!.quotes, hasLength(1));
      expect(quote.quotes.single.serviceCode, 'ECONOMY');
      final busOption = optionFor(
        quoteJson(
          id: 'not-a-product',
          code: 'BUS',
          name: 'Bus',
          iconKey: 'bus',
          capacity: 20,
        ),
      );
      expect(busOption.iconEmoji, '🚗');
    });
  });

  testWidgets('long service names stay readable on the card', (tester) async {
    for (final name in ['Executive Sedan', 'Passenger Van', 'ADA Accessible']) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RideOptionCard(
              option: optionFor(
                quoteJson(
                  id: name,
                  code: 'CODE',
                  name: name,
                  iconKey: 'economy',
                  capacity: 3,
                ),
              ),
              isSelected: true,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text(name), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  test('home/services category content uses codes, not UUIDs', () {
    final codes = PassengerServiceCategories.current.map((e) => e.code).toList();
    expect(codes, [
      'ECONOMY',
      'EXECUTIVE',
      'SUV',
      'VAN',
      'MINIVAN',
      'ADA',
    ]);
    for (final item in PassengerServiceCategories.current) {
      expect(item.code.contains('-'), isFalse);
      expect(RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(item.code), isFalse);
      expect(serviceCategoryIconEmoji(item.iconKey), isNot(equals('🚗')));
    }
    expect(codes, isNot(contains('BIKE')));
    expect(codes, isNot(contains('CNG')));
    expect(codes, isNot(contains('BUS')));
    expect(HomeCategoryIds.economy, 'ECONOMY');
    expect(HomeCategoryIds.ride, 'Ride');
  });

  test('services catalog shows six ride categories without Rentals', () {
    final labels =
        ServicesLocalDatasourceImpl().getCatalog().map((e) => e.label).toList();
    expect(labels, containsAll([
      'Economy Sedan',
      'Executive Sedan',
      'SUV',
      'Passenger Van',
      'Mini-Van',
      'ADA Accessible',
      'Intercity',
      'Reserve',
    ]));
    expect(labels, isNot(contains('Rentals')));
    expect(labels, isNot(contains('Bike')));
    expect(labels, isNot(contains('CNG')));
    expect(labels, isNot(contains('Bus')));
  });

  test('home category presentation includes exactly six backend categories', () {
    final names =
        PassengerServiceCategories.current.map((e) => e.displayName).toList();
    expect(names, [
      'Economy Sedan',
      'Executive Sedan',
      'SUV',
      'Passenger Van',
      'Mini-Van',
      'ADA Accessible',
    ]);
    expect(names, isNot(contains('Rentals')));
    expect(names.length, 6);
  });
}
