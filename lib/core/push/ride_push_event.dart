/// Supported FCM ride-event names from the Passenger push contract.
enum RidePushEventName {
  driverEnRoute,
  arrived,
  inProgress,
  completed,
  cancelled,
  noDrivers;

  static RidePushEventName? tryParse(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'driver_en_route' => RidePushEventName.driverEnRoute,
      'arrived' => RidePushEventName.arrived,
      'in_progress' => RidePushEventName.inProgress,
      'completed' => RidePushEventName.completed,
      'cancelled' || 'canceled' => RidePushEventName.cancelled,
      'no_drivers' || 'no_driver' => RidePushEventName.noDrivers,
      _ => null,
    };
  }
}

/// Parsed FCM ride-event payload. Never treated as booking source of truth.
class RidePushEvent {
  const RidePushEvent({
    required this.bookingId,
    required this.event,
    this.cancelledBy,
    this.source = RidePushSource.unknown,
  });

  final String bookingId;
  final RidePushEventName event;
  final String? cancelledBy;
  final RidePushSource source;

  String get dedupeKey => '$bookingId:${event.wireValue}';

  bool get isActiveEvent =>
      event == RidePushEventName.driverEnRoute ||
      event == RidePushEventName.arrived ||
      event == RidePushEventName.inProgress;

  bool get isTerminalEvent =>
      event == RidePushEventName.completed ||
      event == RidePushEventName.cancelled ||
      event == RidePushEventName.noDrivers;

  /// Parses FCM `data` (string map). Unknown type / unsupported event / missing
  /// fields return null. `accepted` is intentionally not supported.
  static RidePushEvent? tryParse(
    Map<String, dynamic>? data, {
    RidePushSource source = RidePushSource.unknown,
  }) {
    if (data == null || data.isEmpty) return null;
    final type = data['type']?.toString().trim().toLowerCase();
    if (type != 'ride_event') return null;

    final bookingId = data['bookingId']?.toString().trim() ?? '';
    if (bookingId.isEmpty) return null;

    final event = RidePushEventName.tryParse(data['event']?.toString());
    if (event == null) return null;

    final cancelledBy = data['cancelledBy']?.toString().trim();
    return RidePushEvent(
      bookingId: bookingId,
      event: event,
      cancelledBy: cancelledBy == null || cancelledBy.isEmpty
          ? null
          : cancelledBy,
      source: source,
    );
  }
}

enum RidePushSource { foreground, openedApp, coldStart, unknown }

extension RidePushEventNameWire on RidePushEventName {
  String get wireValue => switch (this) {
    RidePushEventName.driverEnRoute => 'driver_en_route',
    RidePushEventName.arrived => 'arrived',
    RidePushEventName.inProgress => 'in_progress',
    RidePushEventName.completed => 'completed',
    RidePushEventName.cancelled => 'cancelled',
    RidePushEventName.noDrivers => 'no_drivers',
  };

  /// Lifecycle rank for stale-push comparison. Terminal events share the top
  /// rank so they are never overridden by an older live event.
  int get lifecycleRank => switch (this) {
    RidePushEventName.driverEnRoute => 2,
    RidePushEventName.arrived => 3,
    RidePushEventName.inProgress => 4,
    RidePushEventName.completed ||
    RidePushEventName.cancelled ||
    RidePushEventName.noDrivers => 5,
  };
}

/// Rank of a booking status / FCM event for stale comparison.
/// `searching`/`offered` exist on REST/socket even though FCM does not send them.
int rideLifecycleRank(String? statusOrEvent) {
  final raw = (statusOrEvent ?? '').trim().toLowerCase();
  return switch (raw) {
    'searching' || 'requested' || 'pending' || 'created' => 0,
    'offered' => 1,
    'accepted' || 'en_route' || 'driver_en_route' => 2,
    'arrived' || 'driver_arrived' => 3,
    'in_progress' || 'ongoing' || 'started' => 4,
    'completed' ||
    'cancelled' ||
    'canceled' ||
    'expired' ||
    'no_drivers' ||
    'no_driver' => 5,
    _ => -1,
  };
}

/// True when [pushEvent] is older than (or equal to, for ignore-duplicate)
/// the authoritative REST/local status.
bool isStaleRidePush({
  required RidePushEventName pushEvent,
  required String? authoritativeStatus,
}) {
  final current = rideLifecycleRank(authoritativeStatus);
  if (current < 0) return false;
  return current > pushEvent.lifecycleRank;
}
