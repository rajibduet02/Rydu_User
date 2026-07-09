import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'rentals_dependencies.dart';

abstract final class RentalLeaveOptions {
  static const now = 'now';
  static const later = 'later';
}

class RentalTimeState {
  const RentalTimeState({
    this.selectedHours = 1,
    this.minHours = 1,
    this.maxHours = 12,
    this.includedKm = 15,
    this.selectedLeaveOption = RentalLeaveOptions.now,
    this.currentPrice = 389.25,
    this.originalPrice = 519.0,
    this.isLoading = false,
    this.errorMessage,
  });

  final int selectedHours;
  final int minHours;
  final int maxHours;
  final int includedKm;
  final String selectedLeaveOption;
  final double currentPrice;
  final double originalPrice;
  final bool isLoading;
  final String? errorMessage;

  RentalTimeState copyWith({
    int? selectedHours,
    int? includedKm,
    String? selectedLeaveOption,
    double? currentPrice,
    double? originalPrice,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RentalTimeState(
      selectedHours: selectedHours ?? this.selectedHours,
      minHours: minHours,
      maxHours: maxHours,
      includedKm: includedKm ?? this.includedKm,
      selectedLeaveOption: selectedLeaveOption ?? this.selectedLeaveOption,
      currentPrice: currentPrice ?? this.currentPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RentalTimeController extends Notifier<RentalTimeState> {
  @override
  RentalTimeState build() {
    final config = ref.read(getRentalTimeConfigUsecaseProvider).call();
    return RentalTimeState(
      minHours: config.minHours,
      maxHours: config.maxHours,
      includedKm: config.kmPerHour,
      currentPrice: config.discountedHourlyRate,
      originalPrice: config.baseHourlyRate,
    );
  }

  RentalTimeState _stateForHours(int hours, String leaveOption) {
    final pricing = ref.read(getRentalPricingUsecaseProvider).call(hours);
    return RentalTimeState(
      selectedHours: pricing.selectedHours,
      minHours: state.minHours,
      maxHours: state.maxHours,
      includedKm: pricing.includedKm,
      selectedLeaveOption: leaveOption,
      currentPrice: pricing.currentPrice,
      originalPrice: pricing.originalPrice,
    );
  }

  void increaseHours() {
    if (state.selectedHours >= state.maxHours) return;
    state = _stateForHours(state.selectedHours + 1, state.selectedLeaveOption);
  }

  void decreaseHours() {
    if (state.selectedHours <= state.minHours) return;
    state = _stateForHours(state.selectedHours - 1, state.selectedLeaveOption);
  }

  void updateHours(int hours) {
    final h = hours.clamp(state.minHours, state.maxHours);
    state = _stateForHours(h, state.selectedLeaveOption);
  }

  void selectLeaveOption(String option) {
    state = _stateForHours(state.selectedHours, option);
    // TODO: When option == later, open schedule picker / calendar flow when product is ready.
  }

  void chooseRide() {
    state = state.copyWith(clearError: true);
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.rentalRideSelection,
          extra: <String, Object?>{
            'selectedType': 'Rentals',
            'rentalHours': state.selectedHours,
            'leaveOption': state.selectedLeaveOption,
          },
        );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void navigateBack() {
    final router = ref.read(goRouterProvider);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(RouteNames.rentals);
    }
  }
}
