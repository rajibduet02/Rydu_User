import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_assignment.dart';
import 'package:rydu_user/features/ride_booking/data/utils/ride_planning_parsers.dart';
import 'package:rydu_user/features/ride_booking/domain/accepted_ride_identity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_tracking/presentation/widgets/driver_info_card.dart';

void main() {
  const serviceCategory = 'Economy Sedan';

  group('accepted booking driver identification', () {
    test('uses the assigned driver name, photo, and rating', () {
      final booking = RidePlanningParsers.booking({
        'id': 'b1',
        'status': 'accepted',
        'driver': {
          'id': 'd1',
          'fullName': 'Mohammad Mohidul Islam',
          'rating': 4.82,
          'profileImageUrl': '/uploads/avatars/drivers/d1.jpg',
          'phone': '01711000000',
        },
      });

      final identity = AcceptedRideIdentity.fromAssignment(
        driver: booking!.driver,
        vehicle: booking.vehicle,
      );

      expect(identity.driverName, 'Mohammad Mohidul Islam');
      expect(identity.profileImageUrl, '/uploads/avatars/drivers/d1.jpg');
      expect(identity.rating, '4.82');
      expect(identity.canCall, isTrue);
      expect(identity.driverName, isNot(serviceCategory));
    });

    test('does not fabricate a rating or photo when they are absent', () {
      final driver = RidePlanningParsers.assignedDriver({
        'id': 'd2',
        'name': 'Karim Ahmed',
      });
      final identity = AcceptedRideIdentity.fromAssignment(driver: driver);
      expect(identity.driverName, 'Karim Ahmed');
      expect(identity.rating, isNull);
      expect(identity.profileImageUrl, isNull);
      expect(identity.canCall, isFalse);
    });
  });

  group('vehicle mapping', () {
    test('maps make, model, color, year, and plate from the booking vehicle', () {
      final vehicle = RidePlanningParsers.bookingVehicle({
        'id': 'v1',
        'make': 'Toyota',
        'model': 'Noah',
        'color': 'White',
        'year': 2019,
        'plateNumber': 'DHA-11-2233',
      });
      final identity = AcceptedRideIdentity.fromAssignment(
        driver: const AssignedDriverEntity(
          id: 'd1',
          name: 'Karim Ahmed',
          vehicleName: serviceCategory,
          plateNumber: 'OLD-PLATE',
        ),
        vehicle: vehicle,
      );

      expect(identity.makeModel, 'Toyota Noah');
      expect(identity.colorYear, 'White · 2019');
      expect(identity.plateNumber, 'DHA-11-2233');
      expect(identity.makeModel, isNot(serviceCategory));
    });

    test('omits missing vehicle fields and does not use the service category', () {
      final identity = AcceptedRideIdentity.fromAssignment(
        driver: const AssignedDriverEntity(
          id: 'd1',
          name: 'Karim Ahmed',
          vehicleName: serviceCategory,
          plateNumber: 'DHA-11-2233',
        ),
      );
      expect(identity.makeModel, isNull);
      expect(identity.colorYear, isNull);
      expect(identity.year, isNull);
      expect(identity.plateNumber, 'DHA-11-2233');
    });

    test('ignores an invalid vehicle year', () {
      final vehicle = RidePlanningParsers.bookingVehicle({'year': 1800});
      expect(vehicle, isNull);
    });
  });

  group('license plate rendering', () {
    testWidgets('shows the plate and hides rating when it is absent', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverInfoCard(
              driverName: 'Karim Ahmed',
              plateNumber: 'DHA-11-2233',
              makeModel: 'Toyota Noah',
              colorYear: 'White',
            ),
          ),
        ),
      );

      expect(find.text('DHA-11-2233'), findsOneWidget);
      expect(find.text('Karim Ahmed'), findsOneWidget);
      expect(find.text('Toyota Noah'), findsOneWidget);
      expect(find.text('White'), findsOneWidget);
      expect(find.textContaining('★'), findsNothing);
      expect(find.text('Plate unavailable'), findsNothing);
      expect(find.byIcon(Icons.phone_outlined), findsNothing);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
    });

    testWidgets('shows a fallback when the plate is missing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverInfoCard(
              driverName: 'Karim Ahmed',
              plateNumber: '',
              rating: '4.9',
              onCall: _noop,
            ),
          ),
        ),
      );

      expect(find.text('Plate unavailable'), findsOneWidget);
      expect(find.text('★ 4.9'), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    });
  });

  group('booking restoration', () {
    test('restored active booking keeps the assigned driver and vehicle', () {
      final booking = RidePlanningParsers.booking({
        'id': 'b-restore',
        'status': 'driver_en_route',
        'bookingNumber': 'RYD-9',
        'driverEtaMinutes': 6,
        'pickup': {'address': 'Dhanmondi', 'latitude': 23.75, 'longitude': 90.37},
        'dropoff': {'address': 'Mirpur', 'latitude': 23.82, 'longitude': 90.36},
        'driver': {
          'id': 'd9',
          'name': 'Nabila Rahman',
          'phone': '01819000000',
          'rating': '4.7',
        },
        'vehicle': {
          'make': 'Honda',
          'model': 'City',
          'color': 'Silver',
          'plateNumber': 'DHA-22-1001',
        },
      });

      final identity = AcceptedRideIdentity.fromAssignment(
        driver: booking!.driver,
        vehicle: booking.vehicle,
        etaMinutes: booking.driverEtaMinutes,
      );

      expect(booking.status, 'driver_en_route');
      expect(identity.driverName, 'Nabila Rahman');
      expect(identity.rating, '4.7');
      expect(identity.makeModel, 'Honda City');
      expect(identity.colorYear, 'Silver');
      expect(identity.plateNumber, 'DHA-22-1001');
      expect(identity.etaLabel, '6 min');
      expect(booking.pickupAddress, 'Dhanmondi');
      expect(booking.dropoffAddress, 'Mirpur');
    });
  });

  group('driver and vehicle reassignment', () {
    test('keeps the ride vehicle when a later status omits it', () {
      final accepted = RideAssignment.mergeSocket(
        current: const RideAssignmentSnapshot(),
        event: {
          'event': 'accepted',
          'status': 'accepted',
          'driver': {'id': 'd1', 'name': 'Karim Ahmed', 'rating': '4.5'},
          'vehicle': {
            'make': 'Toyota',
            'model': 'Noah',
            'plateNumber': 'DHA-11-2233',
          },
        },
        searchingWithoutDriver: false,
      );
      final enRoute = RideAssignment.mergeSocket(
        current: accepted,
        event: {'event': 'status', 'status': 'driver_en_route'},
        searchingWithoutDriver: false,
      );

      expect(enRoute.driver?.name, 'Karim Ahmed');
      expect(enRoute.vehicle?.plateNumber, 'DHA-11-2233');
      expect(enRoute.needsBookingRefresh, isFalse);
    });

    test('status does not clear the vehicle when the driver id changes', () {
      const current = RideAssignmentSnapshot(
        driver: AssignedDriverEntity(id: 'd1', name: 'Karim Ahmed'),
        vehicle: BookingVehicleEntity(
          make: 'Toyota',
          model: 'Noah',
          plateNumber: 'DHA-11-2233',
        ),
        etaMinutes: 4,
      );
      final reassigned = RideAssignment.mergeSocket(
        current: current,
        event: {
          'event': 'status',
          'status': 'accepted',
          'driver': {
            'id': 'd2',
            'name': 'Nabila Rahman',
            'vehicleName': 'Personal Civic',
          },
        },
        searchingWithoutDriver: false,
      );

      expect(reassigned.driver?.id, 'd2');
      expect(reassigned.vehicle?.plateNumber, 'DHA-11-2233');
      expect(reassigned.etaMinutes, 4);
      expect(reassigned.needsBookingRefresh, isFalse);
    });

    test('replaces the vehicle only when the ride payload includes one', () {
      const current = RideAssignmentSnapshot(
        driver: AssignedDriverEntity(id: 'd1', name: 'Karim Ahmed'),
        vehicle: BookingVehicleEntity(plateNumber: 'DHA-11-2233', make: 'Toyota'),
      );
      final exchanged = RideAssignment.mergeSocket(
        current: current,
        event: {
          'event': 'accepted',
          'status': 'accepted',
          'vehicle': {
            'make': 'Honda',
            'model': 'City',
            'color': 'Black',
            'year': 2021,
            'plateNumber': 'DHA-99-0001',
          },
        },
        searchingWithoutDriver: false,
      );

      expect(exchanged.driver?.id, 'd1');
      expect(exchanged.vehicle?.make, 'Honda');
      expect(exchanged.vehicle?.model, 'City');
      expect(exchanged.vehicle?.color, 'Black');
      expect(exchanged.vehicle?.year, 2021);
      expect(exchanged.vehicle?.plateNumber, 'DHA-99-0001');
      expect(exchanged.needsBookingRefresh, isFalse);
    });

    test('clears assignment when dispatch returns to searching', () {
      const current = RideAssignmentSnapshot(
        driver: AssignedDriverEntity(id: 'd1', name: 'Karim Ahmed'),
        vehicle: BookingVehicleEntity(plateNumber: 'DHA-11-2233'),
      );
      final searching = RideAssignment.mergeSocket(
        current: current,
        event: {'event': 'searching', 'status': 'searching'},
        searchingWithoutDriver: true,
      );
      expect(searching.driver, isNull);
      expect(searching.vehicle, isNull);
    });
  });
}

void _noop() {}
