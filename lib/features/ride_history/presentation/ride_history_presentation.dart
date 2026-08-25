import '../../ride_booking/domain/entities/ride_planning_entities.dart';

enum RideHistoryStatusKind { completed, cancelled, expired, other }

abstract final class RideHistoryPresentation {
  static const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static RideHistoryStatusKind kind(String status) {
    return switch (status.toLowerCase()) {
      'completed' => RideHistoryStatusKind.completed,
      'cancelled' || 'canceled' => RideHistoryStatusKind.cancelled,
      'no_drivers' => RideHistoryStatusKind.expired,
      _ => RideHistoryStatusKind.other,
    };
  }

  static String statusLabel(String status) {
    return switch (kind(status)) {
      RideHistoryStatusKind.completed => 'Completed',
      RideHistoryStatusKind.cancelled => 'Cancelled',
      RideHistoryStatusKind.expired => 'Expired',
      RideHistoryStatusKind.other => _titleCase(status),
    };
  }

  static bool isExpired(String status) =>
      kind(status) == RideHistoryStatusKind.expired;

  static bool isCancelled(String status) =>
      kind(status) == RideHistoryStatusKind.cancelled;

  static bool isCompleted(String status) =>
      kind(status) == RideHistoryStatusKind.completed;

  static DateTime? preferredTimestamp(BookingEntity booking) {
    return switch (booking.status.toLowerCase()) {
      'completed' => booking.completedAt ?? booking.createdAt,
      'cancelled' || 'canceled' => booking.cancelledAt ?? booking.createdAt,
      'no_drivers' =>
        booking.cancelledAt ?? booking.completedAt ?? booking.createdAt,
      _ => booking.createdAt ?? booking.completedAt ?? booking.cancelledAt,
    };
  }

  static String formatTimestamp(DateTime value, {DateTime? now}) {
    final local = value.toLocal();
    final current = (now ?? DateTime.now()).toLocal();
    final time = _formatTime(local);
    if (_isSameDay(local, current)) return 'Today, $time';
    if (_isSameDay(local, current.subtract(const Duration(days: 1)))) {
      return 'Yesterday, $time';
    }
    return '${local.day} ${months[local.month - 1]} ${local.year}, $time';
  }

  static String pickupLabel(BookingEntity booking) =>
      booking.pickupAddress?.trim().isNotEmpty == true
      ? booking.pickupAddress!.trim()
      : 'Pickup';

  static String dropoffLabel(BookingEntity booking) =>
      booking.dropoffAddress?.trim().isNotEmpty == true
      ? booking.dropoffAddress!.trim()
      : 'Destination';

  static String routeLabel(BookingEntity booking) =>
      '${pickupLabel(booking)} → ${dropoffLabel(booking)}';

  static String? serviceLabel(BookingEntity booking) {
    final name = booking.serviceName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final code = booking.serviceCode?.trim();
    if (code != null && code.isNotEmpty) return code;
    return null;
  }

  static String? driverVehicleLine(BookingEntity booking) {
    final driverName = booking.driver?.name.trim();
    final vehicle =
        booking.vehicle?.displayLabel ??
        booking.driver?.vehicleName?.trim() ??
        booking.vehicle?.plateNumber ??
        booking.driver?.plateNumber;
    if (driverName != null &&
        driverName.isNotEmpty &&
        vehicle != null &&
        vehicle.isNotEmpty) {
      return '$driverName · $vehicle';
    }
    if (driverName != null && driverName.isNotEmpty) return driverName;
    if (vehicle != null && vehicle.isNotEmpty) return vehicle;
    return null;
  }

  static String? distanceDurationLabel(BookingEntity booking) {
    final parts = <String>[];
    if (booking.distanceKm != null && booking.distanceKm! > 0) {
      parts.add('${booking.distanceKm!.toStringAsFixed(1)} km');
    }
    if (booking.durationMin != null && booking.durationMin! > 0) {
      parts.add('${booking.durationMin} min');
    }
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  static String expiredCopy() => 'No driver was available for this ride.';

  static String _formatTime(DateTime local) {
    var hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _titleCase(String status) {
    final trimmed = status.trim();
    if (trimmed.isEmpty) return 'Unknown';
    final normalized = trimmed.replaceAll('_', ' ');
    return normalized
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}
