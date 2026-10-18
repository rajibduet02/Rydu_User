import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/network/profile_image_url.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_assignment.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/accepted_ride_identity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';

/// Fixed passenger booking contract shared by booking:accepted and REST snapshots.
const _contract = {
  'id': 'bkg_1',
  'bookingId': 'bkg_1',
  'status': 'accepted',
  'etaMinutes': 7,
  'driver': {
    'id': 'drv_1',
    'name': 'Nabila Rahman',
    'phone': '01711000000',
    'profileImageUrl': '/uploads/avatars/drivers/drv_1.jpg',
    'plateNumber': 'DRIVER-PLATE',
  },
  'vehicle': {
    'id': 'veh_1',
    'make': 'Toyota',
    'model': 'Noah',
    'color': 'White',
    'year': 2019,
    'plateNumber': 'DHA-11-2233',
  },
};

void main() {
  group('booking:accepted contract', () {
    test('maps driver, assigned vehicle, and accept-time ETA', () {
      final accepted = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(
          driver: AssignedDriverEntity(id: 'old', name: 'Old Driver'),
          vehicle: BookingVehicleEntity(plateNumber: 'OLD-PLATE'),
          etaMinutes: 2,
        ),
        event: {'event': 'accepted', ..._contract},
        searchingWithoutDriver: false,
      );
      final identity = AcceptedRideIdentity.fromAssignment(
        driver: accepted.driver,
        vehicle: accepted.vehicle,
        etaMinutes: accepted.etaMinutes,
      );

      expect(accepted.driver?.id, 'drv_1');
      expect(accepted.driver?.name, 'Nabila Rahman');
      expect(accepted.driver?.phone, '01711000000');
      expect(
        accepted.driver?.profileImageUrl,
        '/uploads/avatars/drivers/drv_1.jpg',
      );
      expect(accepted.vehicle?.id, 'veh_1');
      expect(accepted.vehicle?.make, 'Toyota');
      expect(accepted.vehicle?.model, 'Noah');
      expect(accepted.vehicle?.color, 'White');
      expect(accepted.vehicle?.year, 2019);
      expect(identity.plateNumber, 'DHA-11-2233');
      expect(identity.plateNumber, isNot('DRIVER-PLATE'));
      expect(identity.etaLabel, '7 min');
      expect(identity.rating, isNull);
      expect(identity.canCall, isTrue);
    });
  });

  group('REST snapshots', () {
    test('active and by-id payloads use the same booking mapping', () {
      final active = RideAssignment.fromBooking(
        RidePlanningParsers.booking(_contract)!,
      );
      final byId = RideAssignment.fromBooking(
        RidePlanningParsers.booking({
          'booking': _contract,
        })!,
      );

      expect(byId.driver?.id, active.driver?.id);
      expect(byId.vehicle?.plateNumber, active.vehicle?.plateNumber);
      expect(byId.vehicle?.year, 2019);
      expect(byId.etaMinutes, 7);

      final source = File(
        'lib/features/ride_booking/data/datasources/passenger_ride_remote_datasource.dart',
      ).readAsStringSync();
      expect(source.contains('RidePlanningParsers.booking'), isTrue);
      expect(
        source.contains("PassengerApiPaths.activeBooking"),
        isTrue,
      );
      expect(source.contains('PassengerApiPaths.bookingById'), isTrue);
    });

    test('a later booking snapshot replaces the previous assignment', () {
      final first = RideAssignment.fromBooking(
        RidePlanningParsers.booking(_contract)!,
      );
      final second = RideAssignment.fromBooking(
        RidePlanningParsers.booking({
          'id': 'bkg_2',
          'status': 'accepted',
          'etaMinutes': null,
          'driver': {
            'id': 'drv_2',
            'name': 'Karim Ahmed',
            'phone': null,
            'profileImageUrl': null,
            'plateNumber': null,
          },
          'vehicle': {
            'id': 'veh_2',
            'make': 'Honda',
            'model': null,
            'color': null,
            'year': null,
            'plateNumber': 'DHA-99-0001',
          },
        })!,
      );
      final identity = AcceptedRideIdentity.fromAssignment(
        driver: second.driver,
        vehicle: second.vehicle,
        etaMinutes: second.etaMinutes,
      );

      expect(second.driver?.id, isNot(first.driver?.id));
      expect(second.vehicle?.plateNumber, isNot(first.vehicle?.plateNumber));
      expect(identity.driverName, 'Karim Ahmed');
      expect(identity.makeModel, 'Honda');
      expect(identity.colorYear, isNull);
      expect(identity.year, isNull);
      expect(identity.plateNumber, 'DHA-99-0001');
      expect(identity.profileImageUrl, isNull);
      expect(identity.canCall, isFalse);
      expect(identity.etaLabel, isNull);
      expect(identity.rating, isNull);
    });
  });

  group('photo, year, plate, and ETA', () {
    test('profile photos resolve absolute and relative URLs', () {
      const origin = 'http://103.208.181.253:3000';
      expect(
        resolveProfileImageUrl(
          'https://cdn.example.com/drivers/drv_1.jpg',
          baseUrl: origin,
        ),
        'https://cdn.example.com/drivers/drv_1.jpg',
      );
      expect(
        resolveProfileImageUrl(
          '/uploads/avatars/drivers/drv_1.jpg',
          baseUrl: '$origin/api/v1/passenger',
        ),
        '$origin/uploads/avatars/drivers/drv_1.jpg',
      );
      expect(resolveProfileImageUrl(null, baseUrl: origin), isNull);
    });

    test('numeric year renders and a null year is omitted', () {
      final withYear = RidePlanningParsers.bookingVehicle({
        'id': 'veh_1',
        'make': 'Toyota',
        'model': 'Noah',
        'color': 'White',
        'year': 2019,
        'plateNumber': 'DHA-11-2233',
      });
      final nullYear = RidePlanningParsers.bookingVehicle({
        'id': 'veh_1',
        'make': 'Toyota',
        'model': 'Noah',
        'year': null,
        'plateNumber': 'DHA-11-2233',
      });

      expect(
        AcceptedRideIdentity.fromAssignment(vehicle: withYear).colorYear,
        'White · 2019',
      );
      expect(nullYear, isNotNull);
      expect(nullYear!.year, isNull);
      expect(
        AcceptedRideIdentity.fromAssignment(vehicle: nullYear).colorYear,
        isNull,
      );
    });

    test('etaMinutes stays the accept-time value across status and location', () {
      final accepted = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(),
        event: {'event': 'accepted', ..._contract},
        searchingWithoutDriver: false,
      );
      final arrived = RideAssignment.mergeSocket(
        current: accepted,
        event: {
          'event': 'status',
          'status': 'arrived',
          'bookingId': 'bkg_1',
          'etaMinutes': 1,
          'vehicle': {
            'id': 'veh_other',
            'make': 'Suzuki',
            'model': 'WagonR',
            'color': 'Red',
            'year': 2024,
            'plateNumber': 'SWITCH-PLATE',
          },
        },
        searchingWithoutDriver: false,
      );

      expect(arrived.etaMinutes, 7);
      expect(arrived.vehicle?.plateNumber, 'DHA-11-2233');
      expect(arrived.driver?.id, 'drv_1');

      final location = RidePlanningParsers.driverLocation({
        'driverId': 'drv_1',
        'bookingId': 'bkg_1',
        'latitude': 23.75,
        'longitude': 90.37,
        'heading': 90,
      });
      expect(location, isNotNull);
      expect(location!.bookingId, 'bkg_1');

      final controller = File(
        'lib/features/ride_booking/presentation/providers/ride_booking_controller.dart',
      ).readAsStringSync();
      final locationMethod = controller.split('void _applyDriverLocation').last;
      final body = locationMethod.split('Future<void> _applyBookingEntity').first;
      expect(body.contains('driverEtaMinutes'), isFalse);
      expect(body.contains('driverLocation: location'), isTrue);
    });
  });

  group('booking isolation', () {
    test('a different booking id is ignored', () {
      expect(
        RideAssignment.eventMatchesBooking(
          {..._contract, 'event': 'accepted', 'bookingId': 'bkg_2'},
          'bkg_1',
        ),
        isFalse,
      );
      expect(
        RideAssignment.eventMatchesBooking(
          {'event': 'status', 'bookingId': 'bkg_1', 'status': 'arrived'},
          'bkg_1',
        ),
        isTrue,
      );
    });

    test('status without driver or vehicle keeps the accepted assignment', () {
      final accepted = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(),
        event: {'event': 'accepted', ..._contract},
        searchingWithoutDriver: false,
      );
      final inProgress = RideAssignment.mergeSocket(
        current: accepted,
        event: {'event': 'status', 'status': 'in_progress', 'bookingId': 'bkg_1'},
        searchingWithoutDriver: false,
      );

      expect(inProgress.driver?.name, 'Nabila Rahman');
      expect(inProgress.driver?.phone, '01711000000');
      expect(inProgress.vehicle?.plateNumber, 'DHA-11-2233');
      expect(inProgress.vehicle?.year, 2019);
      expect(inProgress.etaMinutes, 7);
    });
  });
}
