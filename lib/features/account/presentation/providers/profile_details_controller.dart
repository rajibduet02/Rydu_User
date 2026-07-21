import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../auth/domain/exceptions/auth_exception.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../data/constants/profile_demo_data.dart';
import 'account_dependencies.dart';

const kProfileTabPersonal = 'personal';
const kProfileTabSecurity = 'security';
const kProfileTabPrivacy = 'privacy';

class ProfileDetailsState {
  const ProfileDetailsState({
    this.userName = '',
    this.phoneNumber = '',
    this.email = '',
    this.rating = '',
    this.membershipName = '',
    this.isPhoneVerified = false,
    this.selectedTab = kProfileTabPersonal,
    this.isLoading = false,
    this.errorMessage,
  });

  final String userName;
  final String phoneNumber;
  final String email;
  final String rating;
  final String membershipName;
  final bool isPhoneVerified;
  final String selectedTab;
  final bool isLoading;
  final String? errorMessage;

  ProfileDetailsState copyWith({
    String? userName,
    String? phoneNumber,
    String? email,
    String? rating,
    String? membershipName,
    bool? isPhoneVerified,
    String? selectedTab,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileDetailsState(
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      membershipName: membershipName ?? this.membershipName,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProfileDetailsController extends Notifier<ProfileDetailsState> {
  bool _loadInFlight = false;

  @override
  ProfileDetailsState build() => const ProfileDetailsState(
    userName: ProfileDemoData.userName,
    phoneNumber: ProfileDemoData.phoneNumber,
    email: ProfileDemoData.email,
    rating: ProfileDemoData.rating,
    membershipName: ProfileDemoData.membershipName,
    isPhoneVerified: ProfileDemoData.isPhoneVerified,
  );

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void resetForLogout() {
    _loadInFlight = false;
    state = const ProfileDetailsState(
      userName: ProfileDemoData.userName,
      phoneNumber: ProfileDemoData.phoneNumber,
      email: ProfileDemoData.email,
      rating: ProfileDemoData.rating,
      membershipName: ProfileDemoData.membershipName,
      isPhoneVerified: ProfileDemoData.isPhoneVerified,
    );
  }

  Future<void> loadProfile() async {
    if (_loadInFlight) return;
    _loadInFlight = true;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final profile = await ref.read(getProfileDetailsUsecaseProvider).call();
      state = state.copyWith(
        userName: profile.userName,
        phoneNumber: profile.phoneNumber,
        email: profile.email,
        rating: profile.rating,
        membershipName: profile.membershipName,
        isPhoneVerified: profile.isPhoneVerified,
        isLoading: false,
      );
    } on AuthException catch (e) {
      if (e.statusCode == 401) {
        ref.read(authSessionProvider.notifier).markUnauthenticated();
      }
      state = state.copyWith(isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    } finally {
      _loadInFlight = false;
    }
  }

  void selectTab(String tab) {
    if (tab == kProfileTabPersonal) {
      state = state.copyWith(selectedTab: tab, clearError: true);
    } else if (tab == kProfileTabSecurity) {
      openSecurity();
    } else if (tab == kProfileTabPrivacy) {
      openPrivacy();
    }
  }

  void openNameEdit() {
    ref.read(goRouterProvider).push(RouteNames.editProfileName);
  }

  void openPhoneEdit() {
    ref.read(goRouterProvider).push(RouteNames.editPhone);
  }

  void openEmailEdit() {
    ref.read(goRouterProvider).push(RouteNames.editEmail);
  }

  void openSecurity() {
    ref.read(goRouterProvider).push(RouteNames.security);
  }

  void openPrivacy() {
    ref.read(goRouterProvider).push(RouteNames.privacyAndData);
  }
}
