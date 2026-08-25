import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/push/ride_push_event.dart';
import 'package:rydu_user/core/push/ride_push_recovery.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';

RidePushEvent _event(String name, {String id = 'b1'}) {
  return RidePushEvent.tryParse({
    'type': 'ride_event',
    'bookingId': id,
    'event': name,
  })!;
}

void main() {
  test('active event starts with active booking restore', () {
    expect(
      RidePushRecovery.planTapStart(_event('driver_en_route')).action,
      RidePushRecoveryAction.restoreActive,
    );
    expect(
      RidePushRecovery.planTapStart(_event('arrived')).action,
      RidePushRecoveryAction.restoreActive,
    );
    expect(
      RidePushRecovery.planTapStart(_event('in_progress')).action,
      RidePushRecoveryAction.restoreActive,
    );
  });

  test('terminal event starts with bookingById', () {
    expect(
      RidePushRecovery.planTapStart(_event('completed')).action,
      RidePushRecoveryAction.loadBookingById,
    );
    expect(
      RidePushRecovery.planTapStart(_event('cancelled')).action,
      RidePushRecoveryAction.loadBookingById,
    );
    expect(
      RidePushRecovery.planTapStart(_event('no_drivers')).action,
      RidePushRecoveryAction.loadBookingById,
    );
  });

  test('active-null falls back to bookingById', () {
    final step = RidePushRecovery.afterActiveRestore(
      event: _event('arrived'),
      active: null,
    );
    expect(step.action, RidePushRecoveryAction.loadBookingById);
  });

  test('matching active booking opens live ride', () {
    final step = RidePushRecovery.afterActiveRestore(
      event: _event('arrived'),
      active: const BookingEntity(id: 'b1', status: 'arrived'),
    );
    expect(step.action, RidePushRecoveryAction.openLiveRide);
  });

  test('completed tap opens ride details', () {
    final step = RidePushRecovery.afterBookingById(
      booking: const BookingEntity(id: 'b1', status: 'completed'),
    );
    expect(step.action, RidePushRecoveryAction.openRideDetails);
  });

  test('cancelled tap opens ride details', () {
    final step = RidePushRecovery.afterBookingById(
      booking: const BookingEntity(id: 'b1', status: 'cancelled'),
    );
    expect(step.action, RidePushRecoveryAction.openRideDetails);
  });

  test('no_drivers tap opens ride details', () {
    final step = RidePushRecovery.afterBookingById(
      booking: const BookingEntity(id: 'b1', status: 'no_drivers'),
    );
    expect(step.action, RidePushRecoveryAction.openRideDetails);
  });

  test('404 booking opens activity', () {
    final step = RidePushRecovery.afterBookingById(booking: null);
    expect(step.action, RidePushRecoveryAction.openActivity);
  });

  test('stale live push cannot override completed REST', () {
    final step = RidePushRecovery.reconcileWithAuthoritative(
      event: _event('driver_en_route'),
      booking: const BookingEntity(id: 'b1', status: 'completed'),
    );
    expect(step.action, RidePushRecoveryAction.openRideDetails);
  });

  test('unexpected active bookingById uses live ride', () {
    final step = RidePushRecovery.afterBookingById(
      booking: const BookingEntity(id: 'b1', status: 'arrived'),
    );
    expect(step.action, RidePushRecoveryAction.openLiveRide);
  });
}
