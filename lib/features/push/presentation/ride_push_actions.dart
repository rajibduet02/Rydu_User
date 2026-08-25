import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../../../app/router/route_names.dart';
import '../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../../ride_history/presentation/providers/ride_history_provider.dart';

final pushUserMessageProvider = StateProvider<String?>((ref) => null);

/// Calls existing ride restore / history / router. No second state machine.
abstract interface class RidePushActions {
  Future<bool> restoreActiveBooking({required bool navigate});

  Future<BookingEntity?> loadBookingById(String bookingId);

  String? get currentBookingId;

  String? get currentStatus;

  bool get hasActiveBooking;

  void resumeActiveRide();

  void openRideDetails(String bookingId);

  void openActivity({String? message});
}

class ProviderRidePushActions implements RidePushActions {
  ProviderRidePushActions(this._ref);

  final Ref _ref;

  @override
  Future<bool> restoreActiveBooking({required bool navigate}) {
    return _ref
        .read(rideBookingControllerProvider.notifier)
        .restoreActiveBooking(navigate: navigate);
  }

  @override
  Future<BookingEntity?> loadBookingById(String bookingId) {
    return _ref
        .read(rideHistoryControllerProvider.notifier)
        .loadDetail(bookingId);
  }

  @override
  String? get currentBookingId =>
      _ref.read(rideBookingControllerProvider).bookingId;

  @override
  String? get currentStatus =>
      _ref.read(rideBookingControllerProvider).bookingStatus;

  @override
  bool get hasActiveBooking =>
      _ref.read(rideBookingControllerProvider).hasActiveBooking;

  @override
  void resumeActiveRide() {
    _ref.read(rideBookingControllerProvider.notifier).resumeActiveRide();
  }

  @override
  void openRideDetails(String bookingId) {
    _ref
        .read(goRouterProvider)
        .go('${RouteNames.rideDetails}?rideId=$bookingId');
  }

  @override
  void openActivity({String? message}) {
    if (message != null && message.isNotEmpty) {
      _ref.read(pushUserMessageProvider.notifier).state = message;
    }
    _ref.read(goRouterProvider).go(RouteNames.activity);
  }
}
