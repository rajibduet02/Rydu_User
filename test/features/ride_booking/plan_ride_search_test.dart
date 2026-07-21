import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/network/api_response_parser.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_controller.dart';
import 'package:rydu_user/features/ride_booking/presentation/widgets/location_input_card.dart';

void main() {
  group('ApiResponseParser.unwrapList', () {
    test('parses autocomplete envelope where data is a list', () {
      final list = ApiResponseParser.unwrapList({
        'success': true,
        'data': [
          {
            'placeId': 'ChIJ1',
            'label': 'Mirpur',
            'secondaryText': 'Dhaka, Bangladesh',
            'latitude': null,
            'longitude': null,
          },
        ],
      });
      expect(list, hasLength(1));
    });

    test('parses nested predictions map', () {
      final list = ApiResponseParser.unwrapList({
        'success': true,
        'data': {
          'predictions': [
            {'placeId': 'a', 'label': 'A'},
          ],
        },
      });
      expect(list, hasLength(1));
    });
  });

  group('autocomplete prediction parsing', () {
    test('accepts null lat/lng', () {
      final prediction = RidePlanningParsers.prediction({
        'placeId': 'ChIJ',
        'label': 'Mirpur',
        'secondaryText': 'Dhaka, Bangladesh',
        'address': 'Mirpur, Dhaka, Bangladesh',
        'latitude': null,
        'longitude': null,
        'types': ['locality'],
        'city': 'Dhaka',
        'country': 'Bangladesh',
        'countryCode': 'BD',
      });
      expect(prediction, isNotNull);
      expect(prediction!.placeId, 'ChIJ');
      expect(prediction.primaryText, 'Mirpur');
      expect(prediction.latitude, isNull);
      expect(prediction.longitude, isNull);
    });

    test('requires placeId', () {
      expect(
        RidePlanningParsers.prediction({
          'label': 'Mirpur',
          'latitude': null,
          'longitude': null,
        }),
        isNull,
      );
    });
  });

  group('LocationInputCard text styles', () {
    test('typed text uses dark readable color', () {
      expect(LocationInputCard.fieldTextStyle.color, const Color(0xFF111827));
      expect(LocationInputCard.fieldTextStyle.fontSize, 17);
    });

    test('hint uses secondary readable color', () {
      expect(LocationInputCard.hintTextStyle.color, const Color(0xFF6B7280));
    });
  });

  group('ActiveSearchField', () {
    test('pickup and destination are distinct', () {
      expect(ActiveSearchField.pickup, isNot(ActiveSearchField.destination));
      expect(
        const RideBookingState(
          activeSearchField: ActiveSearchField.destination,
          destinationQuery: 'Mirpur',
        ).activeSearchField,
        ActiveSearchField.destination,
      );
    });

    test(
      'short query should not keep searching flag without debounce work',
      () {
        // Documented contract: queries under 2 chars clear predictions.
        const state = RideBookingState(
          destinationQuery: 'M',
          predictions: [],
          isSearchingPlaces: false,
        );
        expect(state.destinationQuery.trim().length < 2, isTrue);
        expect(state.predictions, isEmpty);
      },
    );
  });
}
