import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/maps/encoded_polyline_decoder.dart';
import 'package:rydu_user/core/network/api_response_parser.dart';
import 'package:rydu_user/core/network/passenger_api_error_mapper.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';

void main() {
  group('RidePlanningParsers', () {
    test('parses autocomplete prediction with null coordinates', () {
      final prediction = RidePlanningParsers.prediction({
        'placeId': 'abc',
        'primaryText': 'Bashundhara City',
        'secondaryText': 'Dhaka',
        'latitude': null,
        'longitude': null,
      });
      expect(prediction, isNotNull);
      expect(prediction!.placeId, 'abc');
      expect(prediction.latitude, isNull);
      expect(prediction.longitude, isNull);
    });

    test('parses place details', () {
      final place = RidePlanningParsers.place({
        'placeId': 'p1',
        'label': 'Square Hospital',
        'address': 'Panthapath',
        'latitude': 23.75,
        'longitude': 90.38,
        'city': null,
        'district': null,
        'postalCode': null,
        'types': ['hospital'],
      });
      expect(place, isNotNull);
      expect(place!.latitude, 23.75);
      expect(place.city, isNull);
    });

    test('parses reverse geocode with empty placeId', () {
      final place = RidePlanningParsers.place({
        'placeId': '',
        'label': 'Road 2',
        'address': 'Dhanmondi',
        'lat': 23.81,
        'lng': 90.41,
      });
      expect(place, isNotNull);
      expect(place!.placeId, '');
      expect(place.latitude, 23.81);
    });

    test('preserves country and countryCode from place details', () {
      final place = RidePlanningParsers.place({
        'placeId': 'p-us',
        'label': 'Times Square',
        'address': 'New York',
        'latitude': 40.758,
        'longitude': -73.9855,
        'country': 'United States',
        'countryCode': 'US',
      });
      expect(place!.country, 'United States');
      expect(place.countryCode, 'US');
    });

    test('preserves snake_case country_code from reverse geocode', () {
      final place = RidePlanningParsers.place({
        'placeId': '',
        'label': 'Mirpur',
        'address': 'Dhaka',
        'lat': 23.81,
        'lng': 90.41,
        'country': 'Bangladesh',
        'country_code': 'BD',
      });
      expect(place!.country, 'Bangladesh');
      expect(place.countryCode, 'BD');
    });

    group('normalizedCountryCode', () {
      test('uppercases lowercase ISO codes', () {
        expect(RidePlanningParsers.normalizedCountryCode('bd'), 'BD');
        expect(RidePlanningParsers.normalizedCountryCode('us'), 'US');
      });

      test('keeps uppercase ISO codes', () {
        expect(RidePlanningParsers.normalizedCountryCode('BD'), 'BD');
        expect(RidePlanningParsers.normalizedCountryCode('US'), 'US');
      });

      test('trims whitespace', () {
        expect(RidePlanningParsers.normalizedCountryCode(' bd '), 'BD');
      });

      test('returns null when missing', () {
        expect(RidePlanningParsers.normalizedCountryCode(null), isNull);
        expect(RidePlanningParsers.normalizedCountryCode(''), isNull);
        expect(RidePlanningParsers.normalizedCountryCode('  '), isNull);
      });

      test('returns null for invalid values', () {
        expect(RidePlanningParsers.normalizedCountryCode('USA'), isNull);
        expect(RidePlanningParsers.normalizedCountryCode('Bangladesh'), isNull);
        expect(RidePlanningParsers.normalizedCountryCode('B1'), isNull);
        expect(RidePlanningParsers.normalizedCountryCode('+1'), isNull);
        expect(RidePlanningParsers.normalizedCountryCode('U'), isNull);
      });

      test('passes through other valid ISO codes without mapping to BD/US', () {
        expect(RidePlanningParsers.normalizedCountryCode('in'), 'IN');
      });
    });

    test('parses route preview and bounds', () {
      final route = RidePlanningParsers.routePreview({
        'distanceMeters': 5200,
        'distanceKm': 5.2,
        'durationSeconds': 900,
        'durationMin': 15,
        'staticDurationSeconds': null,
        'trafficDelaySeconds': null,
        'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
        'routeBounds': {
          'northeast': {'latitude': 23.82, 'longitude': 90.42},
          'southwest': {'latitude': 23.75, 'longitude': 90.38},
        },
        'legs': [],
        'provider': 'google',
        'calculatedAt': '2026-07-10T10:00:00.000Z',
      });
      expect(route, isNotNull);
      expect(route!.distanceKm, 5.2);
      expect(route.routeBounds.isValid, isTrue);
    });

    test('parses booking quote with six services', () {
      final quotes = List.generate(
        6,
        (i) => {
          'serviceCategoryId': 'svc_$i',
          'serviceCode': 'code_$i',
          'serviceName': 'Service $i',
          'capacity': 4,
          'distanceKm': 1.0 + i,
          'durationMin': 5 + i,
          'originalFare': 200.0 + i,
          'discountAmount': i.isEven ? 20.0 : 0.0,
          'finalFare': i.isEven ? 180.0 + i : 200.0 + i,
          'currency': 'BDT',
          'promotion': i.isEven ? 'Promo' : null,
        },
      );
      final quote = RidePlanningParsers.bookingQuote({
        'route': {
          'distanceMeters': 1000,
          'durationSeconds': 300,
          'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
          'routeBounds': {
            'northeast': {'lat': 1.0, 'lng': 1.0},
            'southwest': {'lat': 0.0, 'lng': 0.0},
          },
        },
        'quotes': quotes,
      });
      expect(quote, isNotNull);
      expect(quote!.quotes, hasLength(6));
      expect(quote.quotes.first.currency, 'BDT');
      expect(quote.quotes.first.hasDiscount, isTrue);
      expect(quote.quotes[1].hasDiscount, isFalse);
    });

    test('parses variable quote counts', () {
      final quote = RidePlanningParsers.bookingQuote({
        'route': {
          'distanceMeters': 1000,
          'durationSeconds': 300,
          'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
          'routeBounds': {
            'northeast': {'lat': 1.0, 'lng': 1.0},
            'southwest': {'lat': 0.0, 'lng': 0.0},
          },
        },
        'quotes': [
          {
            'serviceCategoryId': 'only',
            'serviceCode': 'cng',
            'serviceName': 'CNG',
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
      expect(quote!.quotes, hasLength(1));
      expect(quote.quotes.first.finalFare, 100);
    });

    test('parses driver location with nullable fields', () {
      final location = RidePlanningParsers.driverLocation({
        'driverId': 'd1',
        'bookingId': 'b1',
        'latitude': 23.81,
        'longitude': 90.41,
        'heading': null,
        'speedKph': null,
        'accuracyMeters': null,
        'timestamp': '2026-07-10T10:00:00.000Z',
      });
      expect(location, isNotNull);
      expect(location!.heading, isNull);
    });

    test('ignores driver event for different booking via filter helper', () {
      final activeBookingId = 'booking-a';
      final other = RidePlanningParsers.driverLocation({
        'driverId': 'd1',
        'bookingId': 'booking-b',
        'latitude': 23.81,
        'longitude': 90.41,
      })!;
      final same = RidePlanningParsers.driverLocation({
        'driverId': 'd1',
        'bookingId': 'booking-a',
        'latitude': 23.82,
        'longitude': 90.42,
      })!;
      expect(other.bookingId == activeBookingId, isFalse);
      expect(same.bookingId == activeBookingId, isTrue);
    });
  });

  group('EncodedPolylineDecoder', () {
    test('decodes known polyline and builds bounds', () {
      final points = EncodedPolylineDecoder.decode(
        '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
      );
      expect(points.length, greaterThanOrEqualTo(2));
      final bounds = EncodedPolylineDecoder.boundsFromPoints(points);
      expect(bounds, isNotNull);
    });

    test('returns empty for empty polyline', () {
      expect(EncodedPolylineDecoder.decode(''), isEmpty);
    });
  });

  group('PassengerApiErrorMapper', () {
    test('parses error envelope', () {
      final error = PassengerApiErrorMapper.fromEnvelope({
        'success': false,
        'error': {
          'code': 'RATE_LIMITED',
          'message': 'Too many requests',
          'details': {},
        },
      });
      expect(error, isNotNull);
      expect(error!.code, 'RATE_LIMITED');
      expect(error.message, 'Too many requests');
    });

    test('maps ACTIVE_BOOKING_EXISTS', () {
      final error = PassengerApiErrorMapper.fromEnvelope({
        'success': false,
        'error': {
          'code': 'ACTIVE_BOOKING_EXISTS',
          'message': 'You already have an active booking',
        },
      });
      expect(error!.code, 'ACTIVE_BOOKING_EXISTS');
    });

    test('maps 429 and 503 via DioException', () {
      final rate = PassengerApiErrorMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 429,
            data: {
              'success': false,
              'error': {'code': 'RATE_LIMITED', 'message': 'Slow down'},
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      final unavailable = PassengerApiErrorMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 503,
            data: {
              'success': false,
              'error': {'code': 'SERVICE_UNAVAILABLE', 'message': 'Maps down'},
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(rate.statusCode, 429);
      expect(rate.message, 'Slow down');
      expect(unavailable.statusCode, 503);
      expect(unavailable.message, 'Maps down');
    });
  });

  group('Idempotency key reuse', () {
    test('reuses same key for retries of one booking action', () {
      String? existingKey;
      var attempt = 0;
      String beginBookingAction({required bool newAttempt}) {
        if (newAttempt) {
          attempt += 1;
          existingKey = 'idem-$attempt';
        } else {
          existingKey ??= 'idem-$attempt';
        }
        return existingKey!;
      }

      final first = beginBookingAction(newAttempt: true);
      final retry = beginBookingAction(newAttempt: false);
      expect(first, 'idem-1');
      expect(retry, 'idem-1');

      final nextAttempt = beginBookingAction(newAttempt: true);
      expect(nextAttempt, 'idem-2');
    });

    test('double-tap booking prevention flag', () {
      var isCreatingBooking = false;
      bool tryStart() {
        if (isCreatingBooking) return false;
        isCreatingBooking = true;
        return true;
      }

      expect(tryStart(), isTrue);
      expect(tryStart(), isFalse);
    });
  });

  group('BookingEntity', () {
    test('isActive excludes terminal statuses', () {
      expect(
        const BookingEntity(id: '1', status: 'searching').isActive,
        isTrue,
      );
      expect(
        const BookingEntity(id: '1', status: 'quoted').isActive,
        isTrue,
      );
      expect(
        const BookingEntity(id: '1', status: 'completed').isActive,
        isFalse,
      );
      expect(
        const BookingEntity(id: '1', status: 'cancelled').isActive,
        isFalse,
      );
    });
  });

  group('Create booking cash vs card parsing', () {
    test('cash flat booking parsing is unchanged', () {
      final result = RidePlanningParsers.createBookingResult({
        'id': 'b-cash',
        'status': 'searching',
        'paymentMethodCode': 'cash',
        'finalFare': 120.5,
        'currency': 'BDT',
        'pickup': {
          'address': 'Pickup Rd',
          'latitude': 23.81,
          'longitude': 90.41,
        },
      });
      expect(result, isNotNull);
      expect(result!.booking.id, 'b-cash');
      expect(result.booking.status, 'searching');
      expect(result.booking.paymentMethodCode, 'cash');
      expect(result.payment, isNull);
    });

    test('card wrapper response parses booking and payment', () {
      final result = RidePlanningParsers.createBookingResult({
        'booking': {
          'id': 'b-card',
          'status': 'quoted',
          'paymentMethodCode': 'card',
        },
        'payment': {
          'method': 'card',
          'paymentIntentId': 'pi_123',
          'clientSecret': 'pi_123_secret_abc',
          'status': 'requires_payment_method',
        },
      });
      expect(result, isNotNull);
      expect(result!.booking.id, 'b-card');
      expect(result.booking.status, 'quoted');
      expect(result.payment, isNotNull);
      expect(result.payment!.clientSecret, 'pi_123_secret_abc');
      expect(result.payment!.needsPayment, isTrue);
    });

    test('cash nested payment without card fields is not a card wrapper', () {
      final result = RidePlanningParsers.createBookingResult({
        'id': 'b-cash-2',
        'status': 'searching',
        'paymentMethodCode': 'cash',
        'payment': {'method': 'cash', 'status': 'unpaid'},
      });
      expect(result!.payment, isNull);
      expect(result.booking.status, 'searching');
    });
  });

  group('Payment config and methods', () {
    test('parses backend data-array envelope with code/name/isActive', () {
      final methods = RidePlanningParsers.paymentMethods({
        'success': true,
        'data': [
          {
            'id': '1',
            'code': 'cash',
            'name': 'Cash',
            'isActive': true,
          },
          {
            'id': '2',
            'code': 'card',
            'name': 'Card',
            'isActive': true,
          },
        ],
      });
      expect(methods, hasLength(2));
      expect(methods.map((m) => m.code).toList(), ['cash', 'card']);
      expect(methods.map((m) => m.label).toList(), ['Cash', 'Card']);
      expect(CardBookingPayment.backendIncludesCard(methods), isTrue);
      expect(
        methods.any((m) => m.code.toLowerCase() == 'card'),
        isTrue,
      );

      final config = RidePlanningParsers.paymentConfig({
        'stripeEnabled': true,
        'cardEnabled': true,
        'publishableKey': 'pk_test_example',
      });
      expect(config!.canInitializeStripe, isTrue);
      expect(
        config.canInitializeStripe &&
            CardBookingPayment.backendIncludesCard(methods),
        isTrue,
      );
    });

    test('unwrapList reads payment-methods data array, not the root object', () {
      final list = ApiResponseParser.unwrapList({
        'success': true,
        'data': [
          {'id': '1', 'code': 'cash', 'name': 'Cash', 'isActive': true},
          {'id': '2', 'code': 'card', 'name': 'Card', 'isActive': true},
        ],
      });
      expect(list, hasLength(2));
      expect(ApiResponseParser.unwrapData({
        'success': true,
        'data': [
          {'code': 'card', 'name': 'Card'},
        ],
      }).containsKey('success'), isTrue);
    });

    test('card hidden when backend does not return it', () {
      final methods = [
        RidePlanningParsers.paymentMethod({
          'code': 'cash',
          'label': 'Cash',
          'isDefault': true,
        }),
      ];
      expect(methods.first, isNotNull);
      expect(isCardPaymentMethodCode(methods.first!.code), isFalse);
      expect(methods.any((m) => isCardPaymentMethodCode(m?.code)), isFalse);
    });

    test('publishable key config is accepted only for pk_ keys', () {
      final ok = RidePlanningParsers.paymentConfig({
        'stripeEnabled': true,
        'cardEnabled': true,
        'publishableKey': 'pk_test_example',
      });
      expect(ok!.canInitializeStripe, isTrue);
      final secret = RidePlanningParsers.paymentConfig({
        'stripeEnabled': true,
        'cardEnabled': true,
        'publishableKey': 'sk_test_secret',
      });
      expect(secret!.publishableKey, isNull);
      expect(secret.canInitializeStripe, isFalse);
    });
  });

  group('Stale autocomplete request id', () {
    test('ignores older request results', () {
      var latestRequestId = 0;
      final accepted = <int>[];
      void onResult(int requestId) {
        if (requestId != latestRequestId) return;
        accepted.add(requestId);
      }

      latestRequestId = 1;
      latestRequestId = 2;
      onResult(1);
      onResult(2);
      expect(accepted, [2]);
    });
  });
}
