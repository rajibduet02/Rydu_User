import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

const kFamilyProfileAdult = 'adult';
const kFamilyProfileTeen = 'teen';

class FamilyProfileState {
  const FamilyProfileState({
    this.selectedProfileType,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? selectedProfileType;
  final bool isLoading;
  final String? errorMessage;

  FamilyProfileState copyWith({
    String? selectedProfileType,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearProfileType = false,
  }) {
    return FamilyProfileState(
      selectedProfileType: clearProfileType
          ? null
          : (selectedProfileType ?? this.selectedProfileType),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FamilyProfileController extends Notifier<FamilyProfileState> {
  @override
  FamilyProfileState build() => const FamilyProfileState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> selectAdult() async {
    state = state.copyWith(
      isLoading: true,
      selectedProfileType: kFamilyProfileAdult,
      clearError: true,
    );
    try {
      await ref.read(prepareAdultFamilyProfileUsecaseProvider).call();
      state = state.copyWith(isLoading: false);
      ref.read(goRouterProvider).push(RouteNames.addFamilyMember);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not continue as adult.',
      );
    }
  }

  Future<void> selectTeen() async {
    state = state.copyWith(
      isLoading: true,
      selectedProfileType: kFamilyProfileTeen,
      clearError: true,
    );
    try {
      await ref.read(prepareTeenFamilyProfileUsecaseProvider).call();
      state = state.copyWith(isLoading: false);
      ref.read(goRouterProvider).push(RouteNames.inviteTeen);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not continue as teen.',
      );
    }
  }
}
