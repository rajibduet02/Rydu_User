import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';

class RentalsState {
  const RentalsState({
    this.selectedRentalPackage,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? selectedRentalPackage;
  final bool isLoading;
  final String? errorMessage;

  RentalsState copyWith({
    String? selectedRentalPackage,
    bool clearPackage = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RentalsState(
      selectedRentalPackage: clearPackage
          ? null
          : (selectedRentalPackage ?? this.selectedRentalPackage),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RentalsController extends Notifier<RentalsState> {
  @override
  RentalsState build() => const RentalsState();

  /// Opens rental duration and pricing flow before ride booking.
  void startRentalBooking() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.rentalTimeSelection);
  }

  // TODO: Wire package / duration picker when rental catalog API is ready.
  void selectRentalPackage(String packageId) {
    state = state.copyWith(selectedRentalPackage: packageId, clearError: true);
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
