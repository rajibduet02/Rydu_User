import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../ride_booking/domain/constants/passenger_service_categories.dart';
import '../../../ride_booking/presentation/models/ride_booking_route_args.dart';

export '../../domain/constants/service_ids.dart';
import '../../domain/constants/service_ids.dart';

class ServicesState {
  const ServicesState({
    this.selectedService,
    this.selectedBottomNavIndex = 1,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? selectedService;
  final int selectedBottomNavIndex;
  final bool isLoading;
  final String? errorMessage;

  ServicesState copyWith({
    String? selectedService,
    int? selectedBottomNavIndex,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ServicesState(
      selectedService: selectedService ?? this.selectedService,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ServicesController extends Notifier<ServicesState> {
  @override
  ServicesState build() => const ServicesState();

  void resetForServicesTab() {
    state = const ServicesState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void selectService(String service) {
    state = state.copyWith(selectedService: service, clearError: true);
  }

  /// Selects service and navigates per product rules (React `ServicesScreen`).
  Future<void> openService(String service) async {
    selectService(service);
    state = state.copyWith(isLoading: true);
    final router = ref.read(goRouterProvider);
    try {
      switch (service) {
        case ServiceIds.intercity:
          await router.push(RouteNames.intercity);
          break;
        case ServiceIds.reserve:
          await router.push(RouteNames.reserve);
          break;
        case ServiceIds.rentals:
          await router.push(RouteNames.rentals);
          break;
        default:
          if (PassengerServiceCategories.isCurrentRideCode(service)) {
            await router.push(
              RouteNames.rideBooking,
              extra: RideBookingRouteArgs(selectedType: service),
            );
          }
          break;
      }
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Something went wrong. Please try again.',
        isLoading: false,
      );
      return;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectBottomNav(int index) {
    state = state.copyWith(selectedBottomNavIndex: index, clearError: true);
    final router = ref.read(goRouterProvider);
    switch (index) {
      case 0:
        router.go(RouteNames.home);
        break;
      case 1:
        router.go(RouteNames.services);
        break;
      case 2:
        router.go(RouteNames.activity);
        break;
      case 3:
        router.go(RouteNames.account);
        break;
    }
  }
}

final servicesControllerProvider =
    NotifierProvider<ServicesController, ServicesState>(ServicesController.new);
