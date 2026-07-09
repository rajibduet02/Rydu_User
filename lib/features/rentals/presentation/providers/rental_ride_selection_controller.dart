import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../payment/presentation/providers/payment_method_provider.dart';
import '../models/rental_vehicle.dart';
import 'rental_time_controller.dart';
import 'rentals_dependencies.dart';

class RentalRideSelectionState {
  const RentalRideSelectionState({
    this.selectedVehicleId = 'uberx-rentals',
    this.rentalVehicles = const [],
    this.promotionAmount = 171.75,
    this.rentalHours = 1,
    this.leaveOption = RentalLeaveOptions.now,
    this.isLoading = false,
    this.errorMessage,
  });

  final String selectedVehicleId;
  final List<RentalVehicle> rentalVehicles;
  final double promotionAmount;
  final int rentalHours;
  final String leaveOption;
  final bool isLoading;
  final String? errorMessage;

  RentalVehicle? get selectedVehicle {
    for (final v in rentalVehicles) {
      if (v.id == selectedVehicleId) return v;
    }
    return rentalVehicles.isEmpty ? null : rentalVehicles.first;
  }

  RentalRideSelectionState copyWith({
    String? selectedVehicleId,
    List<RentalVehicle>? rentalVehicles,
    double? promotionAmount,
    int? rentalHours,
    String? leaveOption,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RentalRideSelectionState(
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      rentalVehicles: rentalVehicles ?? this.rentalVehicles,
      promotionAmount: promotionAmount ?? this.promotionAmount,
      rentalHours: rentalHours ?? this.rentalHours,
      leaveOption: leaveOption ?? this.leaveOption,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RentalRideSelectionController extends Notifier<RentalRideSelectionState> {
  @override
  RentalRideSelectionState build() {
    final vehicles = ref.read(getRentalVehiclesUsecaseProvider).call(15);
    return RentalRideSelectionState(
      rentalVehicles: vehicles,
      promotionAmount: ref
          .read(getDefaultPromotionAmountUsecaseProvider)
          .call(),
    );
  }

  static int _asInt(Object? raw, int fallback) {
    if (raw == null) return fallback;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString()) ?? fallback;
  }

  void initializeFromExtra(Map<String, dynamic> extra) {
    final hours = _asInt(extra['rentalHours'], state.rentalHours).clamp(1, 12);
    final leave = extra['leaveOption'] as String? ?? RentalLeaveOptions.now;
    final includedKm = hours * 15;

    ref.read(paymentMethodControllerProvider.notifier).reset();

    state = RentalRideSelectionState(
      selectedVehicleId: 'uberx-rentals',
      rentalVehicles: ref
          .read(getRentalVehiclesUsecaseProvider)
          .call(includedKm),
      promotionAmount: ref
          .read(getDefaultPromotionAmountUsecaseProvider)
          .call(),
      rentalHours: hours,
      leaveOption: leave,
      isLoading: false,
      errorMessage: null,
    );
  }

  void selectVehicle(String vehicleId) {
    var found = false;
    for (final v in state.rentalVehicles) {
      if (v.id == vehicleId) {
        found = true;
        break;
      }
    }
    if (!found) return;
    state = state.copyWith(selectedVehicleId: vehicleId, clearError: true);
  }

  void chooseSelectedVehicle() {
    final v = state.selectedVehicle;
    if (v == null) return;
    final payment = ref
        .read(paymentMethodControllerProvider)
        .selectedPaymentMethod;
    state = state.copyWith(clearError: true);
    ref
        .read(goRouterProvider)
        .push(
          RouteNames.rentalDriverFound,
          extra: <String, Object?>{
            'selectedType': 'Rentals',
            'rentalVehicle': v.name,
            'rentalHours': state.rentalHours,
            'leaveOption': state.leaveOption,
            'price': v.price,
            'paymentMethod': payment,
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
      router.go(RouteNames.rentalTimeSelection);
    }
  }
}
