import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../ride_booking/domain/constants/ride_booking_type_ids.dart';
import '../../../ride_booking/presentation/models/ride_booking_route_args.dart';
import 'reserve_dependencies.dart';

class ReserveState {
  const ReserveState({
    this.selectedPickupDate,
    this.selectedPickupTime,
    this.isLoading = false,
    this.errorMessage,
  });

  final DateTime? selectedPickupDate;
  final String? selectedPickupTime;
  final bool isLoading;
  final String? errorMessage;

  ReserveState copyWith({
    DateTime? selectedPickupDate,
    String? selectedPickupTime,
    bool clearPickupDate = false,
    bool clearPickupTime = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReserveState(
      selectedPickupDate: clearPickupDate
          ? null
          : (selectedPickupDate ?? this.selectedPickupDate),
      selectedPickupTime: clearPickupTime
          ? null
          : (selectedPickupTime ?? this.selectedPickupTime),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ReserveController extends Notifier<ReserveState> {
  @override
  ReserveState build() => const ReserveState();

  /// Opens shared plan-your-ride flow with tier [RideBookingTypeIds.reserve].
  void startReserveRide() {
    if (!ref.read(startReserveRideUsecaseProvider).call()) return;
    state = state.copyWith(clearError: true);
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.rideBooking,
          extra: const RideBookingRouteArgs(selectedType: 'Reserve'),
        );
  }

  // TODO: Wire showDatePicker / product calendar when reserve booking UX is ready.
  void selectPickupDate(DateTime date) {
    state = state.copyWith(selectedPickupDate: date, clearError: true);
  }

  // TODO: Wire showTimePicker or slot grid when reserve booking UX is ready.
  void selectPickupTime(String time) {
    state = state.copyWith(selectedPickupTime: time, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void navigateBack() {
    final router = ref.read(goRouterProvider);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(RouteNames.services);
    }
  }
}
