import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../ride_booking/presentation/models/ride_booking_route_args.dart';
import 'home_dependencies.dart';

/// Canonical category / tier ids stored in [HomeState.selectedCategory].
abstract final class HomeCategoryIds {
  static const ride = 'Ride';
  static const bike = 'Bike';
  static const cng = 'CNG';
  static const rentals = 'Rentals';
  static const premium = 'Premium';
  static const comfort = 'Comfort';
}

class HomeState {
  const HomeState({
    this.selectedCategory,
    this.selectedBottomNavIndex = 0,
    this.currentLocationText = 'Where are you?',
    this.hasUnreadNotification = true,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? selectedCategory;
  final int selectedBottomNavIndex;
  final String currentLocationText;
  final bool hasUnreadNotification;
  final bool isLoading;
  final String? errorMessage;

  HomeState copyWith({
    String? selectedCategory,
    bool clearSelectedCategory = false,
    int? selectedBottomNavIndex,
    String? currentLocationText,
    bool? hasUnreadNotification,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      currentLocationText: currentLocationText ?? this.currentLocationText,
      hasUnreadNotification:
          hasUnreadNotification ?? this.hasUnreadNotification,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void resetBottomNav() {
    state = state.copyWith(selectedBottomNavIndex: 0);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final label = await ref.read(getCurrentLocationUsecaseProvider).call();
      state = state.copyWith(currentLocationText: label, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Unable to get location.',
        isLoading: false,
      );
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category, clearError: true);
  }

  /// Opens plan-your-ride flow with the given tier (Ride, Bike, CNG, Premium, …).
  void openRideBooking(String selectedType) {
    state = state.copyWith(selectedCategory: selectedType, clearError: true);
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.rideBooking,
          extra: RideBookingRouteArgs(selectedType: selectedType),
        );
  }

  /// “Where to?” opens plan-your-ride (Ride) so destination entry works in one flow.
  void openSearch() {
    openRideBooking(HomeCategoryIds.ride);
  }

  void openScheduleRide() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.scheduleRide);
  }

  /// Home “Later” shortcut → reserve flow.
  void openReserveFlow() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.reserve);
  }

  void openOffers() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.offers);
  }

  void openRentals() {
    state = state.copyWith(
      selectedCategory: HomeCategoryIds.rentals,
      clearError: true,
    );
    ref.read(goRouterProvider).push(RouteNames.rentals);
  }

  void openNotifications() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.notifications);
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

  /// Green “Go with RYD U CNG” promo.
  void selectPromoCng() {
    openRideBooking(HomeCategoryIds.cng);
  }

  /// Dark “Hop on RYD U” promo (matches React: Bike).
  void selectPromoHopOn() {
    openRideBooking(HomeCategoryIds.bike);
  }

  /// Blue “Premium” promo (React used Ride for premium tier).
  void selectPromoPremium() {
    openRideBooking(HomeCategoryIds.premium);
  }

  /// Dark “Comfort” promo.
  void selectPromoComfort() {
    openRideBooking(HomeCategoryIds.comfort);
  }
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
