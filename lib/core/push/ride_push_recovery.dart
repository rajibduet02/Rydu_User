import '../../features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'ride_push_event.dart';

enum RidePushRecoveryAction {
  ignore,
  restoreActive,
  loadBookingById,
  openLiveRide,
  openRideDetails,
  openActivity,
}

class RidePushRecoveryStep {
  const RidePushRecoveryStep(this.action, {this.message});

  final RidePushRecoveryAction action;
  final String? message;
}

/// Plans REST recovery from an FCM tap. Navigation always follows REST, never
/// the notification payload alone.
abstract final class RidePushRecovery {
  static RidePushRecoveryStep planTapStart(RidePushEvent event) {
    if (event.isActiveEvent) {
      return const RidePushRecoveryStep(RidePushRecoveryAction.restoreActive);
    }
    if (event.isTerminalEvent) {
      return const RidePushRecoveryStep(RidePushRecoveryAction.loadBookingById);
    }
    return const RidePushRecoveryStep(RidePushRecoveryAction.ignore);
  }

  static RidePushRecoveryStep afterActiveRestore({
    required RidePushEvent event,
    required BookingEntity? active,
  }) {
    if (active != null &&
        active.id == event.bookingId &&
        active.isActive) {
      return const RidePushRecoveryStep(RidePushRecoveryAction.openLiveRide);
    }
    return const RidePushRecoveryStep(RidePushRecoveryAction.loadBookingById);
  }

  static RidePushRecoveryStep afterBookingById({
    required BookingEntity? booking,
  }) {
    if (booking == null) {
      return const RidePushRecoveryStep(
        RidePushRecoveryAction.openActivity,
        message: 'This ride is no longer available.',
      );
    }
    if (booking.isActive) {
      return const RidePushRecoveryStep(RidePushRecoveryAction.openLiveRide);
    }
    return const RidePushRecoveryStep(RidePushRecoveryAction.openRideDetails);
  }

  /// After REST, if the push is older than server state, still use REST
  /// navigation — never open a live ride from a stale live event when the
  /// booking is already terminal.
  static RidePushRecoveryStep reconcileWithAuthoritative({
    required RidePushEvent event,
    required BookingEntity booking,
  }) {
    if (booking.isActive) {
      return const RidePushRecoveryStep(RidePushRecoveryAction.openLiveRide);
    }
    if (isStaleRidePush(
      pushEvent: event.event,
      authoritativeStatus: booking.status,
    )) {
      return const RidePushRecoveryStep(RidePushRecoveryAction.openRideDetails);
    }
    return afterBookingById(booking: booking);
  }
}
