import '../../domain/entities/ride_planning_entities.dart';
import 'ride_planning_parsers.dart';

/// Driver and ride-vehicle identity currently shown for an accepted booking.
class RideAssignmentSnapshot {
  const RideAssignmentSnapshot({
    this.driver,
    this.vehicle,
    this.etaMinutes,
    this.needsBookingRefresh = false,
  });

  final AssignedDriverEntity? driver;

  /// Vehicle from the booking/assignment payload. Not the service category.
  final BookingVehicleEntity? vehicle;
  final int? etaMinutes;

  /// True when the driver changed and this event did not include a vehicle.
  final bool needsBookingRefresh;
}

/// Applies booking socket payloads without substituting a service-category car
/// or a driver's unrelated fleet vehicle.
abstract final class RideAssignment {
  static int statusRank(String status) {
    return switch (status.toLowerCase()) {
      'accepted' => 2,
      'en_route' || 'driver_en_route' => 3,
      'arrived' || 'driver_arrived' => 4,
      'in_progress' || 'ongoing' || 'started' => 5,
      'completed' ||
      'cancelled' ||
      'canceled' ||
      'expired' ||
      'no_drivers' ||
      'no_driver' => 6,
      _ => 0,
    };
  }

  static bool isTerminalStatus(String status) => statusRank(status) >= 6;

  /// A late searching event must not clear an assignment already accepted.
  static bool isStalePreAssignment({
    required String currentStatus,
    required String incomingStatus,
    required bool incomingHasDriver,
    required bool incomingHasVehicle,
  }) {
    if (incomingHasDriver || incomingHasVehicle) return false;
    final currentRank = statusRank(currentStatus);
    return currentRank >= 2 && statusRank(incomingStatus) < currentRank;
  }

  /// Keeps the further-along status when a late snapshot is still searching.
  static String preferStatus({
    required String currentStatus,
    required String incomingStatus,
    required bool sameBooking,
  }) {
    if (!sameBooking || currentStatus.isEmpty) return incomingStatus;
    if (isTerminalStatus(incomingStatus)) return incomingStatus;
    if (statusRank(currentStatus) > statusRank(incomingStatus)) {
      return currentStatus;
    }
    return incomingStatus;
  }

  /// Applies a REST snapshot without replacing a newer socket assignment
  /// with a missing driver, vehicle, or ETA.
  static RideAssignmentSnapshot reconcileSnapshot({
    required RideAssignmentSnapshot current,
    required String? currentBookingId,
    required BookingEntity booking,
  }) {
    final incoming = fromBooking(booking);
    final sameBooking =
        currentBookingId == null ||
        currentBookingId.isEmpty ||
        currentBookingId == booking.id;
    if (!sameBooking || isTerminalStatus(booking.status)) return incoming;
    return RideAssignmentSnapshot(
      driver: incoming.driver ?? current.driver,
      vehicle: incoming.vehicle ?? current.vehicle,
      etaMinutes: incoming.etaMinutes ?? current.etaMinutes,
    );
  }

  /// Replaces any previous assignment. Used for active and by-id snapshots.
  static RideAssignmentSnapshot fromBooking(BookingEntity booking) {
    return RideAssignmentSnapshot(
      driver: booking.driver,
      vehicle: booking.vehicle,
      etaMinutes: booking.driverEtaMinutes ?? booking.driver?.etaMinutes,
    );
  }

  /// Drops socket payloads that belong to another booking.
  static bool eventMatchesBooking(
    Map<String, dynamic> event,
    String activeBookingId,
  ) {
    final id =
        event['bookingId']?.toString() ?? event['booking_id']?.toString();
    if (id == null || id.isEmpty) return true;
    return id == activeBookingId;
  }

  static RideAssignmentSnapshot mergeSocket({
    required RideAssignmentSnapshot current,
    required Map<String, dynamic> event,
    required bool searchingWithoutDriver,
  }) {
    final nested = event['booking'];
    final nestedMap = nested is Map
        ? Map<String, dynamic>.from(nested)
        : null;

    final incomingDriver = RidePlanningParsers.assignedDriver(
      event['driver'] ?? event['assignedDriver'] ?? nestedMap?['driver'],
    );

    final vehicleOnEvent = event.containsKey('vehicle');
    final vehicleOnNested =
        nestedMap != null && nestedMap.containsKey('vehicle');
    final vehicleFieldPresent = vehicleOnEvent || vehicleOnNested;
    if (searchingWithoutDriver &&
        incomingDriver == null &&
        !vehicleFieldPresent) {
      return const RideAssignmentSnapshot();
    }
    final incomingVehicle = vehicleFieldPresent
        ? RidePlanningParsers.bookingVehicle(
            vehicleOnEvent ? event['vehicle'] : nestedMap?['vehicle'],
          )
        : null;

    final eventName = (event['event'] ?? '').toString().toLowerCase();
    // Status updates change ride phase only. Identity and the accept-time
    // ETA stay as they were set by booking:accepted or a booking snapshot.
    if (eventName == 'status') {
      return RideAssignmentSnapshot(
        driver: incomingDriver ?? current.driver,
        vehicle: current.vehicle,
        etaMinutes: current.etaMinutes,
      );
    }

    final nextDriver = incomingDriver ?? current.driver;
    final driverChanged = _driverChanged(current.driver, incomingDriver);

    BookingVehicleEntity? nextVehicle;
    var clearVehicle = false;
    if (vehicleFieldPresent) {
      nextVehicle = incomingVehicle;
      clearVehicle = incomingVehicle == null;
    } else if (driverChanged) {
      clearVehicle = true;
    } else {
      nextVehicle = current.vehicle;
    }

    return RideAssignmentSnapshot(
      driver: nextDriver,
      vehicle: clearVehicle ? null : nextVehicle,
      etaMinutes: _etaMinutes(
        event: event,
        incomingDriver: incomingDriver,
        driverChanged: driverChanged,
        currentEta: current.etaMinutes,
      ),
      needsBookingRefresh: driverChanged && !vehicleFieldPresent,
    );
  }

  static bool _driverChanged(
    AssignedDriverEntity? current,
    AssignedDriverEntity? incoming,
  ) {
    if (incoming == null || current == null) return false;
    final nextId = incoming.id.trim();
    final previousId = current.id.trim();
    if (nextId.isEmpty || previousId.isEmpty) return false;
    if (nextId == 'driver' || previousId == 'driver') return false;
    return nextId != previousId;
  }

  static int? _etaMinutes({
    required Map<String, dynamic> event,
    required AssignedDriverEntity? incomingDriver,
    required bool driverChanged,
    required int? currentEta,
  }) {
    if (incomingDriver?.etaMinutes != null) return incomingDriver!.etaMinutes;
    if (event.containsKey('driverEtaMinutes') ||
        event.containsKey('etaMinutes')) {
      final raw = event['driverEtaMinutes'] ?? event['etaMinutes'];
      if (raw is num) return raw.round();
      if (raw is String) return int.tryParse(raw.trim());
      return null;
    }
    if (driverChanged) return null;
    return currentEta;
  }
}
