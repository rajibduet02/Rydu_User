import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../auth/domain/exceptions/auth_exception.dart';
import '../../../auth/presentation/providers/auth_dependencies.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../../ride_booking/presentation/providers/ride_booking_dependencies.dart';
import 'account_dependencies.dart';
import 'profile_details_provider.dart';

class AccountState {
  const AccountState({
    this.userName = 'Mir Efaj',
    this.membershipName = 'RYD U One',
    this.rating = '5.0',
    this.rideCount = 127,
    this.walletBalance = 'BDT 250.00',
    this.hasUnreadInbox = true,
    this.savedPlacesCount = 4,
    this.appVersion = 'v4.629.10001',
    this.isLoading = false,
    this.errorMessage,
    this.selectedBottomNavIndex = 3,
  });

  final String userName;
  final String membershipName;
  final String rating;
  final int rideCount;
  final String walletBalance;
  final bool hasUnreadInbox;
  final int savedPlacesCount;
  final String appVersion;
  final bool isLoading;
  final String? errorMessage;
  final int selectedBottomNavIndex;

  AccountState copyWith({
    String? userName,
    String? membershipName,
    String? rating,
    int? rideCount,
    String? walletBalance,
    bool? hasUnreadInbox,
    int? savedPlacesCount,
    String? appVersion,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? selectedBottomNavIndex,
  }) {
    return AccountState(
      userName: userName ?? this.userName,
      membershipName: membershipName ?? this.membershipName,
      rating: rating ?? this.rating,
      rideCount: rideCount ?? this.rideCount,
      walletBalance: walletBalance ?? this.walletBalance,
      hasUnreadInbox: hasUnreadInbox ?? this.hasUnreadInbox,
      savedPlacesCount: savedPlacesCount ?? this.savedPlacesCount,
      appVersion: appVersion ?? this.appVersion,
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

  void resetForAccountTab() {
    state = const AccountState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> loadAccountData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await ref.read(getAccountProfileUsecaseProvider).call();
      state = state.copyWith(
        userName: profile.userName,
        membershipName: profile.membershipName,
        rating: profile.rating,
        rideCount: profile.rideCount,
        walletBalance: profile.walletBalance,
        hasUnreadInbox: profile.hasUnreadInbox,
        savedPlacesCount: profile.savedPlacesCount,
        appVersion: profile.appVersion,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Could not refresh account.',
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    if (_logoutInFlight) return;
    _logoutInFlight = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(logoutUsecaseProvider).call();
      await ref.read(passengerSocketServiceProvider).disconnect();
      ref.read(authSessionProvider.notifier).markUnauthenticated();
      ref.read(profileDetailsControllerProvider.notifier).resetForLogout();
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

  void _push(String location) {
    ref.read(goRouterProvider).push(location);
  }

  void openEditProfile() => _push(RouteNames.profileDetails);
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
