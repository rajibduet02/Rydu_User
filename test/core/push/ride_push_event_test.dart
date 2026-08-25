import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/push/ride_push_dedupe.dart';
import 'package:rydu_user/core/push/ride_push_event.dart';
import 'package:rydu_user/core/push/ride_updates_channel.dart';

void main() {
  group('RidePushEvent.tryParse', () {
    test('unknown FCM type ignored', () {
      expect(
        RidePushEvent.tryParse({
          'type': 'promo',
          'bookingId': 'b1',
          'event': 'arrived',
        }),
        isNull,
      );
    });

    test('malformed payload ignored', () {
      expect(RidePushEvent.tryParse({}), isNull);
      expect(RidePushEvent.tryParse({'type': 'ride_event'}), isNull);
      expect(
        RidePushEvent.tryParse({'type': 'ride_event', 'bookingId': 'b1'}),
        isNull,
      );
      expect(
        RidePushEvent.tryParse({'type': 'ride_event', 'event': 'arrived'}),
        isNull,
      );
    });

    test('driver_en_route parsed', () {
      final event = RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'abc',
        'event': 'driver_en_route',
      });
      expect(event, isNotNull);
      expect(event!.event, RidePushEventName.driverEnRoute);
      expect(event.isActiveEvent, isTrue);
      expect(event.dedupeKey, 'abc:driver_en_route');
    });

    test('arrived parsed', () {
      expect(
        RidePushEvent.tryParse({
          'type': 'ride_event',
          'bookingId': 'abc',
          'event': 'arrived',
        })!.event,
        RidePushEventName.arrived,
      );
    });

    test('in_progress parsed', () {
      expect(
        RidePushEvent.tryParse({
          'type': 'ride_event',
          'bookingId': 'abc',
          'event': 'in_progress',
        })!.event,
        RidePushEventName.inProgress,
      );
    });

    test('completed parsed', () {
      final event = RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'abc',
        'event': 'completed',
      });
      expect(event!.isTerminalEvent, isTrue);
      expect(event.event, RidePushEventName.completed);
    });

    test('cancelled parsed', () {
      final event = RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'abc',
        'event': 'cancelled',
        'cancelledBy': 'driver',
      });
      expect(event!.event, RidePushEventName.cancelled);
      expect(event.cancelledBy, 'driver');
    });

    test('no_drivers parsed', () {
      expect(
        RidePushEvent.tryParse({
          'type': 'ride_event',
          'bookingId': 'abc',
          'event': 'no_drivers',
        })!.event,
        RidePushEventName.noDrivers,
      );
    });

    test('accepted is not expected', () {
      expect(
        RidePushEvent.tryParse({
          'type': 'ride_event',
          'bookingId': 'abc',
          'event': 'accepted',
        }),
        isNull,
      );
    });
  });

  test('ride_updates channel configuration', () {
    expect(RideUpdatesChannel.id, 'ride_updates');
    expect(RideUpdatesChannel.name, 'Ride updates');
    expect(RideUpdatesChannel.importance.toString(), contains('high'));
  });

  test('duplicate bookingId+event is recorded once', () {
    final dedupe = RidePushDedupe();
    expect(dedupe.record('abc:arrived'), isFalse);
    expect(dedupe.record('abc:arrived'), isTrue);
    expect(dedupe.seen('abc:arrived'), isTrue);
  });

  test('stale en-route cannot override later REST completed', () {
    expect(
      isStaleRidePush(
        pushEvent: RidePushEventName.driverEnRoute,
        authoritativeStatus: 'completed',
      ),
      isTrue,
    );
    expect(
      isStaleRidePush(
        pushEvent: RidePushEventName.arrived,
        authoritativeStatus: 'completed',
      ),
      isTrue,
    );
    expect(
      isStaleRidePush(
        pushEvent: RidePushEventName.driverEnRoute,
        authoritativeStatus: 'arrived',
      ),
      isTrue,
    );
    expect(
      isStaleRidePush(
        pushEvent: RidePushEventName.arrived,
        authoritativeStatus: 'searching',
      ),
      isFalse,
    );
  });
}
