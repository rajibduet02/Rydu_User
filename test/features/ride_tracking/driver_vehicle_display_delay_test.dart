import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_assignment.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/accepted_ride_identity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';

const _accepted = {
  'event': 'accepted',
  'bookingId': 'bkg_1',
  'status': 'accepted',
  'etaMinutes': 6,
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
  group('immediate socket acceptance', () {
    test('booking:accepted fills name, vehicle, plate, and ETA in one merge', () {
      final accepted = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(),
        event: _accepted,
        searchingWithoutDriver: false,
      );
      final identity = AcceptedRideIdentity.fromAssignment(
        driver: accepted.driver,
        vehicle: accepted.vehicle,
        etaMinutes: accepted.etaMinutes,
      );

      expect(identity.driverName, 'Nabila Rahman');
      expect(identity.makeModel, 'Toyota Noah');
      expect(identity.plateNumber, 'DHA-11-2233');
      expect(identity.etaLabel, '6 min');
      expect(identity.profileImageUrl, isNotNull);
      expect(accepted.needsBookingRefresh, isFalse);
    });

    test('a second identical accept does not clear the card', () {
      final first = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(),
        event: _accepted,
        searchingWithoutDriver: false,
      );
      final duplicate = RideAssignment.mergeSocket(
        current: first,
        event: _accepted,
        searchingWithoutDriver: false,
      );
      expect(duplicate.driver?.id, 'drv_1');
      expect(duplicate.vehicle?.plateNumber, 'DHA-11-2233');
      expect(duplicate.etaMinutes, 6);
    });
  });

  group('delayed or older REST snapshot', () {
    test('searching REST does not wipe a socket assignment', () {
      final socket = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(),
        event: _accepted,
        searchingWithoutDriver: false,
      );
      final stale = RidePlanningParsers.booking({
        'id': 'bkg_1',
        'status': 'searching',
        'driver': null,
        'vehicle': null,
        'etaMinutes': null,
      })!;
      final kept = RideAssignment.reconcileSnapshot(
        current: socket,
        currentBookingId: 'bkg_1',
        booking: stale,
      );
      final status = RideAssignment.preferStatus(
        currentStatus: 'accepted',
        incomingStatus: stale.status,
        sameBooking: true,
      );

      expect(kept.driver?.name, 'Nabila Rahman');
      expect(kept.vehicle?.plateNumber, 'DHA-11-2233');
      expect(kept.etaMinutes, 6);
      expect(status, 'accepted');
    });

    test('a complete later snapshot can still refresh the same booking', () {
      final socket = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(),
        event: _accepted,
        searchingWithoutDriver: false,
      );
      final fresh = RidePlanningParsers.booking({
        'id': 'bkg_1',
        'status': 'driver_en_route',
        'etaMinutes': 6,
        'driver': _accepted['driver'],
        'vehicle': _accepted['vehicle'],
      })!;
      final reconciled = RideAssignment.reconcileSnapshot(
        current: socket,
        currentBookingId: 'bkg_1',
        booking: fresh,
      );
      expect(reconciled.driver?.id, 'drv_1');
      expect(reconciled.vehicle?.make, 'Toyota');
      expect(
        RideAssignment.preferStatus(
          currentStatus: 'accepted',
          incomingStatus: 'driver_en_route',
          sameBooking: true,
        ),
        'driver_en_route',
      );
    });
  });

  group('ordering and booking isolation', () {
    test('a searching event after accept is stale', () {
      expect(
        RideAssignment.isStalePreAssignment(
          currentStatus: 'accepted',
          incomingStatus: 'searching',
          incomingHasDriver: false,
          incomingHasVehicle: false,
        ),
        isTrue,
      );
      expect(
        RideAssignment.isStalePreAssignment(
          currentStatus: 'searching',
          incomingStatus: 'accepted',
          incomingHasDriver: true,
          incomingHasVehicle: true,
        ),
        isFalse,
      );
    });

    test('another booking snapshot does not keep the previous driver', () {
      final current = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(),
        event: _accepted,
        searchingWithoutDriver: false,
      );
      final other = RidePlanningParsers.booking({
        'id': 'bkg_2',
        'status': 'searching',
      })!;
      final replaced = RideAssignment.reconcileSnapshot(
        current: current,
        currentBookingId: 'bkg_1',
        booking: other,
      );
      expect(replaced.driver, isNull);
      expect(replaced.vehicle, isNull);
      expect(
        RideAssignment.eventMatchesBooking(
          {'bookingId': 'bkg_2', 'event': 'accepted'},
          'bkg_1',
        ),
        isFalse,
      );
    });
  });
}
