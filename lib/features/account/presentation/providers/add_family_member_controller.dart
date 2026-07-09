import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

const kMemberTypeTeen = 'teen';
const kMemberTypeAdult = 'adult';
const kMemberTypeSenior = 'senior';

class AddFamilyMemberState {
  const AddFamilyMemberState({
    this.selectedMemberType,
    this.isLoading = false,
    this.errorMessage,
  });

  final String? selectedMemberType;
  final bool isLoading;
  final String? errorMessage;

  bool get canContinue => selectedMemberType != null;

  AddFamilyMemberState copyWith({
    String? selectedMemberType,
    bool clearMemberType = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddFamilyMemberState(
      selectedMemberType: clearMemberType
          ? null
          : (selectedMemberType ?? this.selectedMemberType),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AddFamilyMemberController extends Notifier<AddFamilyMemberState> {
  @override
  AddFamilyMemberState build() => const AddFamilyMemberState();

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void selectMemberType(String type) {
    if (type != kMemberTypeTeen &&
        type != kMemberTypeAdult &&
        type != kMemberTypeSenior) {
      return;
    }
    state = state.copyWith(selectedMemberType: type, clearError: true);
  }

  Future<void> continueFlow() async {
    final type = state.selectedMemberType;
    if (type == null) {
      state = state.copyWith(errorMessage: 'Select a member type to continue.');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(continueFamilyMemberFlowUsecaseProvider).call(type);
      state = state.copyWith(isLoading: false);

      final router = ref.read(goRouterProvider);
      switch (type) {
        case kMemberTypeTeen:
          router.push(RouteNames.addParentGuardian);
        case kMemberTypeAdult:
          router.push(RouteNames.familyAdultSetup);
        case kMemberTypeSenior:
          router.push(RouteNames.familySeniorSetup);
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not continue. Try again.',
      );
    }
  }
}
