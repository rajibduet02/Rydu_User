import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';

class RentalDriverFoundState {
  const RentalDriverFoundState({
    this.rentalId = '#REN-5421',
    this.driverName = 'MOHAMMAD MOHIDUL ISLAM',
    this.vehiclePlate = 'DHM-LA-63-525',
    this.startingPoint = '35 Road No. 2',
    this.rentalHours = 1,
    this.includedKm = 15,
    this.paymentMethod = 'Card',
    this.startingInMinutes = 2,
    this.isDetailsExpanded = true,
    this.selectedCancelReason,
    this.isCancelling = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String rentalId;
  final String driverName;
  final String vehiclePlate;
  final String startingPoint;
  final int rentalHours;
  final int includedKm;
  final String paymentMethod;
  final int startingInMinutes;
  final bool isDetailsExpanded;
  final String? selectedCancelReason;
  final bool isCancelling;
  final bool isLoading;
  final String? errorMessage;

  RentalDriverFoundState copyWith({
    String? rentalId,
    String? driverName,
    String? vehiclePlate,
    String? startingPoint,
    int? rentalHours,
    int? includedKm,
    String? paymentMethod,
    int? startingInMinutes,
    bool? isDetailsExpanded,
    String? selectedCancelReason,
    bool? isCancelling,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedCancelReason = false,
  }) {
    return RentalDriverFoundState(
      rentalId: rentalId ?? this.rentalId,
      driverName: driverName ?? this.driverName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      startingPoint: startingPoint ?? this.startingPoint,
      rentalHours: rentalHours ?? this.rentalHours,
      includedKm: includedKm ?? this.includedKm,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      startingInMinutes: startingInMinutes ?? this.startingInMinutes,
      isDetailsExpanded: isDetailsExpanded ?? this.isDetailsExpanded,
      selectedCancelReason: clearSelectedCancelReason
          ? null
          : (selectedCancelReason ?? this.selectedCancelReason),
      isCancelling: isCancelling ?? this.isCancelling,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class RentalDriverFoundController extends Notifier<RentalDriverFoundState> {
  @override
  RentalDriverFoundState build() => const RentalDriverFoundState();

  static int _asInt(Object? raw, int fallback) {
    if (raw == null) return fallback;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString()) ?? fallback;
  }

  void initializeFromExtra(Map<String, dynamic> extra) {
    final hours = _asInt(extra['rentalHours'], 1).clamp(1, 24);
    final km = hours * 15;
    final rawPay = extra['paymentMethod'] as String? ?? 'Card';
    final pay = rawPay.trim().isEmpty || rawPay.toLowerCase() == 'cash'
        ? 'Card'
        : rawPay;

    state = RentalDriverFoundState(
      rentalId: '#REN-5421',
      driverName: 'MOHAMMAD MOHIDUL ISLAM',
      vehiclePlate: 'DHM-LA-63-525',
      startingPoint: '35 Road No. 2',
      rentalHours: hours,
      includedKm: km,
      paymentMethod: pay,
      startingInMinutes: 2,
      isDetailsExpanded: true,
      selectedCancelReason: null,
      isCancelling: false,
      isLoading: false,
      errorMessage: null,
    );
  }

  void toggleDetails() {
    state = state.copyWith(isDetailsExpanded: !state.isDetailsExpanded);
  }

  /// Returns a user-facing message when calling is not wired yet.
  String? callDriver() {
    state = state.copyWith(clearError: true);
    // TODO: Launch tel: / in-app VoIP when call integration is ready.
    return 'Calling the driver is not configured yet.';
  }

  void openChat() {
    state = state.copyWith(clearError: true);
    ref.read(goRouterProvider).push(RouteNames.chat);
  }

  /// Returns a user-facing message when native share is not wired yet.
  String? shareTripStatus() {
    state = state.copyWith(clearError: true);
    // TODO: Use share_plus / dynamic link when share pipeline is ready.
    return 'Sharing trip status is not configured yet.';
  }

  void selectCancelReason(String reason) {
    state = state.copyWith(selectedCancelReason: reason, clearError: true);
  }

  void cancelRental(String reason) {
    selectCancelReason(reason);
    state = state.copyWith(isCancelling: true, clearError: true);
    // TODO: POST cancel rental with [reason] when API is ready.
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      ref.read(goRouterProvider).go(RouteNames.home);
    });
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void navigateBack() {
    final router = ref.read(goRouterProvider);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(RouteNames.rentalRideSelection);
    }
  }
}
