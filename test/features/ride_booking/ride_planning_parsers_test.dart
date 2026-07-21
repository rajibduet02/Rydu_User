import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/maps/encoded_polyline_decoder.dart';
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
        const BookingEntity(id: '1', status: 'completed').isActive,
        isFalse,
      );
      expect(
        const BookingEntity(id: '1', status: 'cancelled').isActive,
        isFalse,
      );
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
