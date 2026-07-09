import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../models/emergency_contact.dart';
import 'account_dependencies.dart';

const kSafetyTipShareLocation = 'share_live_location';
const kSafetyTipLockDoors = 'lock_doors_manually';

class SafetyResourcesState {
  const SafetyResourcesState({
    this.isLoading = false,
    this.errorMessage,
    this.expandedTip,
    this.emergencyContacts = const [],
    this.snackMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? expandedTip;
  final List<EmergencyContact> emergencyContacts;
  final String? snackMessage;

  SafetyResourcesState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? expandedTip,
    bool clearExpandedTip = false,
    List<EmergencyContact>? emergencyContacts,
    String? snackMessage,
    bool clearSnack = false,
  }) {
    return SafetyResourcesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      expandedTip: clearExpandedTip ? null : (expandedTip ?? this.expandedTip),
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
    );
  }
}

class SafetyResourcesController extends Notifier<SafetyResourcesState> {
  @override
  SafetyResourcesState build() {
    Future.microtask(loadResources);
    return const SafetyResourcesState();
  }

  Future<void> loadResources() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final contacts = await ref
          .read(getEmergencyContactsUsecaseProvider)
          .call();
      state = state.copyWith(emergencyContacts: contacts, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load safety resources.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSnack() {
    state = state.copyWith(clearSnack: true);
  }

  void openSosGuide() {
    ref.read(goRouterProvider).push(RouteNames.sosGuide);
  }

  void shareLiveLocation() {
    state = state.copyWith(
      snackMessage:
          'Live location sharing coming soon. (TODO: share integration)',
      clearError: true,
    );
  }

  void toggleEmergencyTip(String tip) {
    final next = state.expandedTip == tip ? null : tip;
    state = state.copyWith(
      expandedTip: next,
      clearExpandedTip: next == null,
      clearError: true,
    );
  }

  Future<void> callPoliceDispatch() async {
    await _callContact('police', 'Calling Police Dispatch...');
  }

  Future<void> callRoadsideAssistance() async {
    await _callContact('roadside', 'Calling Roadside Assistance...');
  }

  EmergencyContact? _contactById(String id) {
    for (final e in state.emergencyContacts) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> _callContact(String id, String snack) async {
    if (_contactById(id) == null) return;
    state = state.copyWith(snackMessage: snack, clearError: true);
  }

  void openCallSupport() {
    ref.read(goRouterProvider).push(RouteNames.callSupport);
  }

  void openLiveChat() {
    ref.read(goRouterProvider).push(RouteNames.liveChat);
  }
}
