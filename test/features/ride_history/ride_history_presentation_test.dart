import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_history/presentation/ride_history_presentation.dart';

void main() {
  group('RideHistoryPresentation status mapping', () {
    test('completed maps to Completed', () {
      expect(RideHistoryPresentation.statusLabel('completed'), 'Completed');
      expect(RideHistoryPresentation.isCompleted('completed'), isTrue);
    });

    test('cancelled and canceled map to Cancelled', () {
      expect(RideHistoryPresentation.statusLabel('cancelled'), 'Cancelled');
      expect(RideHistoryPresentation.statusLabel('canceled'), 'Cancelled');
      expect(RideHistoryPresentation.isCancelled('cancelled'), isTrue);
    });

    test('no_drivers maps to Expired, not Completed or Cancelled', () {
      expect(RideHistoryPresentation.statusLabel('no_drivers'), 'Expired');
      expect(RideHistoryPresentation.isExpired('no_drivers'), isTrue);
      expect(RideHistoryPresentation.isCompleted('no_drivers'), isFalse);
      expect(RideHistoryPresentation.isCancelled('no_drivers'), isFalse);
      expect(
        RideHistoryPresentation.kind('no_drivers'),
        RideHistoryStatusKind.expired,
      );
    });

    test('unknown historical status is not searching', () {
      expect(RideHistoryPresentation.statusLabel('refunded'), 'Refunded');
      expect(
        RideHistoryPresentation.kind('refunded'),
        isNot(RideHistoryStatusKind.completed),
      );
    });
  });

  group('RideHistoryPresentation timestamps', () {
    test('completed prefers completedAt', () {
      final booking = BookingEntity(
        id: '1',
        status: 'completed',
        createdAt: DateTime.utc(2026, 8, 1, 8),
        completedAt: DateTime.utc(2026, 8, 17, 10),
      );
      expect(
        RideHistoryPresentation.preferredTimestamp(booking),
        DateTime.utc(2026, 8, 17, 10),
      );
    });

    test('cancelled prefers cancelledAt', () {
      final booking = BookingEntity(
        id: '1',
        status: 'cancelled',
        createdAt: DateTime.utc(2026, 8, 1, 8),
        cancelledAt: DateTime.utc(2026, 8, 17, 11),
      );
      expect(
        RideHistoryPresentation.preferredTimestamp(booking),
        DateTime.utc(2026, 8, 17, 11),
      );
    });

    test('no_drivers uses createdAt when no terminal timestamp', () {
      final booking = BookingEntity(
        id: '1',
        status: 'no_drivers',
        createdAt: DateTime.utc(2026, 8, 17, 5),
      );
      expect(
        RideHistoryPresentation.preferredTimestamp(booking),
        DateTime.utc(2026, 8, 17, 5),
      );
    });

    test('formats today, yesterday, and calendar dates in local time', () {
      final now = DateTime(2026, 8, 17, 16);
      expect(
        RideHistoryPresentation.formatTimestamp(
          DateTime(2026, 8, 17, 16, 20),
          now: now,
        ),
        'Today, 4:20 PM',
      );
      expect(
        RideHistoryPresentation.formatTimestamp(
          DateTime(2026, 8, 16, 20, 15),
          now: now,
        ),
        'Yesterday, 8:15 PM',
      );
      expect(
        RideHistoryPresentation.formatTimestamp(
          DateTime(2026, 8, 10, 11, 30),
          now: now,
        ),
        '10 Aug 2026, 11:30 AM',
      );
    });
  });

  group('RidePlanningParsers history booking payload', () {
    test('parses nested history fields including cancellation reason', () {
      final booking = RidePlanningParsers.booking({
        'id': 'bkg_1',
        'bookingNumber': 'RYD-100',
        'status': 'cancelled',
        'createdAt': '2026-08-17T05:00:00.000Z',
        'cancelledAt': '2026-08-17T05:12:00.000Z',
        'cancelledBy': 'passenger',
        'cancellationReason': 'Wait time was too long',
        'pickup': {'address': 'Dhanmondi', 'latitude': 23.75, 'longitude': 90.37},
        'dropoff': {'address': 'Mirpur', 'latitude': 23.82, 'longitude': 90.36},
        'route': {
          'distanceKm': 8.4,
          'durationMin': 22,
          'encodedPolyline': '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
        },
        'service': {
          'serviceCategoryId': 'cng',
          'serviceCode': 'cng',
          'serviceName': 'CNG',
        },
        'fare': {
          'amount': 180.5,
          'estimatedAmount': 200,
          'discountAmount': 19.5,
          'currency': 'BDT',
        },
        'payment': {
          'methodCode': 'cash',
          'methodName': 'Cash',
          'status': 'unpaid',
        },
        'driver': {
          'id': 'd1',
          'name': 'Karim',
          'phone': '01700',
          'plateNumber': 'DHA-11',
        },
        'vehicle': {
          'id': 'v1',
          'make': 'Toyota',
          'model': 'Noah',
          'color': 'White',
          'plateNumber': 'DHA-11',
        },
        'recording': {'available': true},
      });

      expect(booking, isNotNull);
      expect(booking!.bookingNumber, 'RYD-100');
      expect(booking.status, 'cancelled');
      expect(booking.serviceName, 'CNG');
      expect(booking.serviceCode, 'cng');
      expect(booking.finalFare, 180.5);
      expect(booking.currency, 'BDT');
      expect(booking.paymentMethodName, 'Cash');
      expect(booking.paymentStatus, 'unpaid');
      expect(booking.distanceKm, 8.4);
      expect(booking.durationMin, 22);
      expect(booking.driver?.name, 'Karim');
      expect(booking.vehicle?.make, 'Toyota');
      expect(booking.recordingAvailable, isTrue);
      expect(booking.cancellationReason, 'Wait time was too long');
      expect(booking.cancelledAt, isNotNull);
      expect(booking.createdAt, isNotNull);
      expect(booking.formattedFare, 'BDT 180.50');
    });

    test('flat active booking payload still parses', () {
      final booking = RidePlanningParsers.booking({
        'id': 'active-1',
        'status': 'searching',
        'serviceName': 'Bike',
        'pickupAddress': 'Banani',
        'dropoffAddress': 'Gulshan',
        'finalFare': 90,
        'currency': 'BDT',
      });
      expect(booking!.isActive, isTrue);
      expect(booking.serviceName, 'Bike');
      expect(booking.pickupAddress, 'Banani');
    });
  });
}
