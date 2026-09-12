import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/ride_booking/data/utils/booking_create_request.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/presentation/models/airport_fare_presentation.dart';
import 'package:rydu_user/features/ride_booking/presentation/models/ride_vehicle_option.dart';
import 'package:rydu_user/features/ride_booking/presentation/widgets/airport_fare_breakdown.dart';

Map<String, dynamic> _route() => {
  'distanceMeters': 1000,
  'durationSeconds': 300,
  'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
  'routeBounds': {
    'northeast': {'lat': 1.0, 'lng': 1.0},
    'southwest': {'lat': 0.0, 'lng': 0.0},
  },
};

Map<String, dynamic> _regularService() => {
  'serviceCategoryId': 'svc_1',
  'serviceCode': 'ride',
  'serviceName': 'Ride',
  'capacity': 4,
  'distanceKm': 5,
  'durationMin': 12,
  'originalFare': 1500,
  'discountAmount': 0,
  'finalFare': 1500,
  'currency': 'BDT',
};

void main() {
  group('airport fare quote parsing', () {
    test('A. regular quote parses unchanged', () {
      final quote = RidePlanningParsers.bookingQuote({
        'route': _route(),
        'quotes': [_regularService()],
      });
      expect(quote, isNotNull);
      expect(quote!.quotes, hasLength(1));
      expect(quote.quotes.first.finalFare, 1500);
      expect(quote.quotes.first.currency, 'BDT');
      expect(quote.quotes.first.airport, isNull);
      expect(quote.quotes.first.airportFee, 0);
      expect(quote.quotes.first.hasAirportSurcharge, isFalse);
    });

    test('B. airport pickup quote parses', () {
      final quote = RidePlanningParsers.bookingQuote({
        'route': _route(),
        'quotes': [
          {
            ..._regularService(),
            'regularFare': 1500,
            'airportFee': 200,
            'finalFare': 1700,
            'airport': {
              'id': 'ap-1',
              'code': 'SAN',
              'name': 'San Diego International',
              'tripType': 'pickup',
            },
          },
        ],
      });
      final service = quote!.quotes.first;
      expect(service.airport?.tripType, 'pickup');
      expect(service.airport?.code, 'SAN');
      expect(service.hasAirportSurcharge, isTrue);
    });

    test('C. airport drop-off quote parses', () {
      final quote = RidePlanningParsers.bookingQuote({
        'route': _route(),
        'quotes': [
          {
            ..._regularService(),
            'regularFare': 1500,
            'airportFee': 200,
            'finalFare': 1700,
            'airport': {
              'code': 'SAN',
              'name': 'San Diego International',
              'tripType': 'dropoff',
            },
          },
        ],
      });
      expect(quote!.quotes.first.airport?.tripType, 'dropoff');
    });

    test('D. regularFare parsed correctly', () {
      final service = RidePlanningParsers.serviceQuote({
        ..._regularService(),
        'regularFare': 1500,
        'airportFee': 200,
        'finalFare': 1700,
      })!;
      expect(service.regularFare, 1500);
      expect(service.displayTripFare, 1500);
    });

    test('E. airportFee parsed correctly', () {
      final service = RidePlanningParsers.serviceQuote({
        ..._regularService(),
        'airport_fee': 200,
        'finalFare': 1700,
      })!;
      expect(service.airportFee, 200);
    });

    test('F. total fare remains backend total', () {
      final service = RidePlanningParsers.serviceQuote({
        ..._regularService(),
        'regularFare': 1500,
        'airportFee': 200,
        'finalFare': 1700,
      })!;
      expect(service.finalFare, 1700);
      final option = rideOptionFromQuote(service);
      expect(option.price, 'BDT 1700.00');
      expect(option.finalFare, 1700);
    });

    test('G. airport object nullable', () {
      final service = RidePlanningParsers.serviceQuote(_regularService())!;
      expect(service.airport, isNull);
      expect(RidePlanningParsers.airportInfo(null), isNull);
      expect(RidePlanningParsers.airportInfo({}), isNull);
    });

    test('U. older response without airport fields does not crash', () {
      final quote = RidePlanningParsers.bookingQuote({
        'route': _route(),
        'quotes': [
          {
            'serviceCategoryId': 'legacy',
            'serviceName': 'Ride',
            'capacity': 4,
            'distanceKm': 2,
            'durationMin': 8,
            'originalFare': 100,
            'discountAmount': 0,
            'finalFare': 100,
            'currency': 'BDT',
          },
        ],
      });
      expect(quote!.quotes.first.airportFee, 0);
      expect(quote.quotes.first.airport, isNull);
      expect(quote.quotes.first.finalFare, 100);
    });

    test('envelope airport applies to services', () {
      final quote = RidePlanningParsers.bookingQuote({
        'route': _route(),
        'regularFare': 1400,
        'airportFee': 250,
        'airport': {'code': 'DAC', 'tripType': 'pickup'},
        'quotes': [_regularService()],
      });
      expect(quote!.quotes.first.airportFee, 250);
      expect(quote.quotes.first.regularFare, 1400);
      expect(quote.quotes.first.airport?.code, 'DAC');
    });

    test('currency mismatch shape (fee 0, no airport) is regular', () {
      final service = RidePlanningParsers.serviceQuote({
        ..._regularService(),
        'airportFee': 0,
        'airport': null,
      })!;
      expect(service.hasAirportSurcharge, isFalse);
      expect(
        AirportFarePresentation.fromOption(rideOptionFromQuote(service)),
        isNull,
      );
    });

    test('booking snapshot parses airport when backend sends it', () {
      final booking = RidePlanningParsers.booking({
        'id': 'b1',
        'status': 'completed',
        'currency': 'BDT',
        'finalFare': 1700,
        'fare': {
          'amount': 1700,
          'currency': 'BDT',
          'regularFare': 1500,
          'airportFee': 200,
          'airport': {'code': 'DAC', 'tripType': 'dropoff'},
        },
      })!;
      expect(booking.regularFare, 1500);
      expect(booking.airportFee, 200);
      expect(booking.airport?.code, 'DAC');
      expect(booking.hasAirportSurcharge, isTrue);
    });
  });

  group('airport fare display', () {
    test('H. no airport row for regular trip', () {
      final option = rideOptionFromQuote(
        RidePlanningParsers.serviceQuote(_regularService())!,
      );
      expect(AirportFarePresentation.fromOption(option), isNull);
    });

    test('I. pickup label renders correctly', () {
      expect(
        AirportFarePresentation.feeLabel(
          const AirportQuoteEntity(code: 'SAN', tripType: 'pickup'),
        ),
        'SAN Airport Pickup Fee',
      );
    });

    test('J. drop-off label renders correctly', () {
      expect(
        AirportFarePresentation.feeLabel(
          const AirportQuoteEntity(code: 'SAN', tripType: 'dropoff'),
        ),
        'SAN Airport Drop-Off Fee',
      );
      expect(
        AirportFarePresentation.feeLabel(
          const AirportQuoteEntity(code: 'SAN', tripType: 'drop_off'),
        ),
        'SAN Airport Drop-Off Fee',
      );
    });

    test('K. airport code/name comes from backend', () {
      expect(
        AirportFarePresentation.feeLabel(
          const AirportQuoteEntity(
            code: 'DAC',
            name: 'Hazrat Shahjalal International',
            tripType: 'pickup',
          ),
        ),
        'DAC Airport Pickup Fee',
      );
      expect(
        AirportFarePresentation.feeLabel(
          const AirportQuoteEntity(
            name: 'Hazrat Shahjalal International',
            tripType: 'dropoff',
          ),
        ),
        'Hazrat Shahjalal International Airport Drop-Off Fee',
      );
    });

    test('does not expose raw tripType enums', () {
      final label = AirportFarePresentation.feeLabel(
        const AirportQuoteEntity(code: 'DAC', tripType: 'pickup'),
      );
      expect(label.contains('pickup'), isFalse);
      expect(label.contains('dropoff'), isFalse);
    });

    test('S. BDT regular money format unchanged', () {
      expect(AirportFarePresentation.money('BDT', 155.84), 'BDT 155.84');
      final option = rideOptionFromQuote(
        RidePlanningParsers.serviceQuote(_regularService())!,
      );
      expect(option.price, 'BDT 1500.00');
    });

    test('does not choose USD from a US airport', () {
      final service = RidePlanningParsers.serviceQuote({
        ..._regularService(),
        'regularFare': 1500,
        'airportFee': 200,
        'finalFare': 1700,
        'currency': 'BDT',
        'airport': {'code': 'SAN', 'tripType': 'pickup'},
      })!;
      expect(service.currency, 'BDT');
      expect(rideOptionFromQuote(service).price.startsWith('BDT'), isTrue);
      expect(rideOptionFromQuote(service).price.startsWith('USD'), isFalse);
    });

    testWidgets('breakdown widget shows trip fare, fee, total', (tester) async {
      final data = AirportFarePresentation.fromOption(
        RideOptionEntity(
          id: 's',
          name: 'Ride',
          category: 'recommended',
          time: '12 min',
          description: 'ride',
          price: 'BDT 1700.00',
          currency: 'BDT',
          finalFare: 1700,
          regularFare: 1500,
          airportFee: 200,
          airport: const AirportQuoteEntity(code: 'SAN', tripType: 'pickup'),
        ),
      )!;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AirportFareBreakdown(data: data)),
        ),
      );
      expect(find.text('Trip Fare'), findsOneWidget);
      expect(find.text('SAN Airport Pickup Fee'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('BDT 1500.00'), findsOneWidget);
      expect(find.text('BDT 200.00'), findsOneWidget);
      expect(find.text('BDT 1700.00'), findsOneWidget);
      expect(find.text('Airport Fee ৳0'), findsNothing);
    });
  });

  group('place IDs on quote/booking payloads', () {
    test('M. pickup Place ID sent when available', () {
      final body = BookingCreateRequest.body(
        serviceCategoryId: 'svc',
        pickup: const LatLngWaypoint(
          latitude: 23.85,
          longitude: 90.40,
          placeId: 'ChIJ-pickup',
        ),
        dropoff: const LatLngWaypoint(latitude: 23.75, longitude: 90.38),
        paymentMethodCode: 'card',
      );
      expect(body['pickup']['placeId'], 'ChIJ-pickup');
    });

    test('N. drop-off Place ID sent when available', () {
      final body = BookingCreateRequest.body(
        serviceCategoryId: 'svc',
        pickup: const LatLngWaypoint(latitude: 23.85, longitude: 90.40),
        dropoff: const LatLngWaypoint(
          latitude: 23.75,
          longitude: 90.38,
          placeId: 'ChIJ-drop',
        ),
        paymentMethodCode: 'card',
      );
      expect(body['dropoff']['placeId'], 'ChIJ-drop');
    });

    test('O. missing Place IDs remain valid', () {
      final pickup = const LatLngWaypoint(
        latitude: 23.85,
        longitude: 90.40,
        placeId: '',
      ).toJson();
      final dropoff = const LatLngWaypoint(
        latitude: 23.75,
        longitude: 90.38,
      ).toJson();
      expect(pickup.containsKey('placeId'), isFalse);
      expect(dropoff.containsKey('placeId'), isFalse);
      final body = BookingCreateRequest.body(
        serviceCategoryId: 'svc',
        pickup: const LatLngWaypoint(latitude: 23.85, longitude: 90.40),
        dropoff: const LatLngWaypoint(latitude: 23.75, longitude: 90.38),
        paymentMethodCode: 'card',
      );
      expect(body['pickup']['latitude'], 23.85);
      expect(body['dropoff']['longitude'], 90.38);
      expect(body.containsKey('airportId'), isFalse);
      expect(body.containsKey('airportFee'), isFalse);
      expect(body.containsKey('airportTripType'), isFalse);
    });
  });

  group('no local airport/FX logic', () {
    test('L. no SAN hardcode in passenger lib', () {
      final hits = <String>[];
      for (final file in Directory('lib').listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        final text = file.readAsStringSync();
        if (text.contains("'SAN'") || text.contains('"SAN"')) {
          hits.add(file.path);
        }
      }
      expect(hits, isEmpty, reason: hits.join(', '));
    });

    test('P. no local geofence calculation', () {
      for (final path in [
        'lib/features/ride_booking/presentation/providers/ride_booking_controller.dart',
        'lib/features/ride_booking/data/utils/ride_planning_parsers.dart',
        'lib/features/ride_booking/presentation/models/airport_fare_presentation.dart',
      ]) {
        final text = File(path).readAsStringSync().toLowerCase();
        expect(text.contains('geofence'), isFalse, reason: path);
        expect(text.contains('haversine'), isFalse, reason: path);
      }
    });

    test('Q. no local airport-fee calculation', () {
      final parser = File(
        'lib/features/ride_booking/data/utils/ride_planning_parsers.dart',
      ).readAsStringSync();
      expect(parser.contains('airportFee *'), isFalse);
      expect(parser.contains('airportFee='), isFalse);
      final presentation = File(
        'lib/features/ride_booking/presentation/models/airport_fare_presentation.dart',
      ).readAsStringSync();
      expect(presentation.contains('exchange'), isFalse);
    });

    test('R. no FX logic', () {
      for (final path in [
        'lib/features/ride_booking/presentation/models/airport_fare_presentation.dart',
        'lib/features/ride_booking/data/utils/ride_planning_parsers.dart',
        'lib/features/ride_booking/presentation/providers/ride_booking_controller.dart',
      ]) {
        final text = File(path).readAsStringSync().toLowerCase();
        expect(text.contains('exchange rate'), isFalse, reason: path);
        expect(text.contains('convertcurrency'), isFalse, reason: path);
        expect(text.contains('foreign exchange'), isFalse, reason: path);
        expect(RegExp(r'\bfx\b').hasMatch(text), isFalse, reason: path);
      }
    });

    test('T. payment flow still uses backend PaymentIntent', () {
      final controller = File(
        'lib/features/ride_booking/presentation/providers/ride_booking_controller.dart',
      ).readAsStringSync();
      expect(controller.contains('clientSecret'), isTrue);
      expect(controller.contains('presentPaymentSheet'), isTrue);
      expect(controller.contains('airportFee +'), isFalse);
      expect(controller.contains('regularFare +'), isFalse);
      final body = BookingCreateRequest.body(
        serviceCategoryId: 'svc',
        pickup: const LatLngWaypoint(latitude: 1, longitude: 2),
        dropoff: const LatLngWaypoint(latitude: 3, longitude: 4),
        paymentMethodCode: 'card',
      );
      expect(body.containsKey('amount'), isFalse);
      expect(body.containsKey('airportFee'), isFalse);
      expect(body.containsKey('regularFare'), isFalse);
    });
  });
}
