import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../auth/domain/exceptions/auth_exception.dart';
import '../../../auth/presentation/providers/auth_dependencies.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../../../ride_history/presentation/providers/ride_history_provider.dart';
import '../../domain/passenger_profile_error_codes.dart';
import 'passenger_profile_controller.dart';

class AccountState {
  const AccountState({
    this.isLoading = false,
    this.errorMessage,
    this.selectedBottomNavIndex = 3,
  });

  final bool isLoading;
  final String? errorMessage;
  final int selectedBottomNavIndex;

  AccountState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? selectedBottomNavIndex,
  }) {
    return AccountState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }
}

class AccountController extends Notifier<AccountState> {
  bool _logoutInFlight = false;

  @override
  AccountState build() => const AccountState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> logout() async {
    if (_logoutInFlight) return;
    _logoutInFlight = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(logoutUsecaseProvider).call();
      await ref.read(passengerSocketServiceProvider).disconnect();
      ref.read(authSessionProvider.notifier).markUnauthenticated();
      ref.read(passengerProfileControllerProvider.notifier).clear();
      ref.invalidate(rideHistoryControllerProvider);
      state = const AccountState();
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not sign out. Please try again.',
      );
    } finally {
      _logoutInFlight = false;
    }
  }

  Future<bool> deactivateAccount() async {
    if (ref.read(rideBookingControllerProvider).hasActiveBooking) {
      state = state.copyWith(
        errorMessage: PassengerProfileErrorCodes.activeRideBlocksDeactivate,
      );
      return false;
    }
    final ok = await ref
        .read(passengerProfileControllerProvider.notifier)
        .deactivate(confirm: true);
    if (!ok) {
      final profileError = ref.read(passengerProfileControllerProvider);
      state = state.copyWith(
        errorMessage:
            profileError.errorMessage ??
            'Could not deactivate your account. Please try again.',
      );
      return false;
    }
    await logout();
    return state.errorMessage == null;
  }

  void _push(String location) {
    ref.read(goRouterProvider).push(location);
  }

  void openEditProfile() => _push(RouteNames.editProfile);
  void openProfileDetails() => _push(RouteNames.profileDetails);
  void openWallet() => _push(RouteNames.wallet);
  void openHelp() => _push(RouteNames.helpCenter);
  void openSafety() => _push(RouteNames.safetyCenter);
  void openInbox() => _push(RouteNames.inbox);
  void openRideHistory() => _push(RouteNames.rideHistory);
  void openSavedPlaces() => _push(RouteNames.savedPlaces);
  void openMembership() => _push(RouteNames.membership);
  void openBusinessTravel() => _push(RouteNames.businessTravel);
  void openFamily() => _push(RouteNames.family);
  void openSettings() => _push(RouteNames.settings);

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

final accountControllerProvider =
    NotifierProvider<AccountController, AccountState>(AccountController.new);
