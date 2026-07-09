import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import 'account_dependencies.dart';

class SafetyCenterState {
  const SafetyCenterState({
    this.configuredFeaturesCount = 0,
    this.totalFeaturesCount = 0,
    this.emergencyContactsCount = 0,
    this.trustedContactsCount = 0,
    this.isTripSharingEnabled = false,
    this.isLoading = false,
    this.errorMessage,
    this.snackMessage,
  });

  final int configuredFeaturesCount;
  final int totalFeaturesCount;
  final int emergencyContactsCount;
  final int trustedContactsCount;
  final bool isTripSharingEnabled;
  final bool isLoading;
  final String? errorMessage;
  final String? snackMessage;

  double get setupProgress => totalFeaturesCount <= 0
      ? 0
      : configuredFeaturesCount / totalFeaturesCount;

  SafetyCenterState copyWith({
    int? configuredFeaturesCount,
    int? totalFeaturesCount,
    int? emergencyContactsCount,
    int? trustedContactsCount,
    bool? isTripSharingEnabled,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? snackMessage,
    bool clearSnack = false,
  }) {
    return SafetyCenterState(
      configuredFeaturesCount:
          configuredFeaturesCount ?? this.configuredFeaturesCount,
      totalFeaturesCount: totalFeaturesCount ?? this.totalFeaturesCount,
      emergencyContactsCount:
          emergencyContactsCount ?? this.emergencyContactsCount,
      trustedContactsCount: trustedContactsCount ?? this.trustedContactsCount,
      isTripSharingEnabled: isTripSharingEnabled ?? this.isTripSharingEnabled,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      snackMessage: clearSnack ? null : (snackMessage ?? this.snackMessage),
    );
  }
}

class SafetyCenterController extends Notifier<SafetyCenterState> {
  @override
  SafetyCenterState build() => const SafetyCenterState();

  void _push(String location) {
    ref.read(goRouterProvider).push(location);
  }

  Future<void> loadSafetyData() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSnack: true);
    try {
      final data = await ref.read(getSafetyCenterDataUsecaseProvider).call();
      state = state.copyWith(
        configuredFeaturesCount: data.configuredFeaturesCount,
        totalFeaturesCount: data.totalFeaturesCount,
        emergencyContactsCount: data.emergencyContactsCount,
        trustedContactsCount: data.trustedContactsCount,
        isTripSharingEnabled: data.isTripSharingEnabled,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load safety settings.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSnack() {
    state = state.copyWith(clearSnack: true);
  }

  void configureEmergencySos() {
    _push(RouteNames.emergencySos);
  }

  Future<void> enableTripSharing() async {
    try {
      final data = await ref.read(enableTripSharingUsecaseProvider).call();
      state = state.copyWith(
        configuredFeaturesCount: data.configuredFeaturesCount,
        totalFeaturesCount: data.totalFeaturesCount,
        emergencyContactsCount: data.emergencyContactsCount,
        trustedContactsCount: data.trustedContactsCount,
        isTripSharingEnabled: data.isTripSharingEnabled,
        snackMessage:
            'Trip sharing will be enabled here. (TODO: backend + location)',
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Could not enable trip sharing.');
    }
  }

  void manageEmergencyContacts() {
    _push(RouteNames.emergencyContacts);
  }

  void addTrustedContacts() {
    _push(RouteNames.trustedContacts);
  }

  void openRideCheck() {
    _push(RouteNames.rideCheck);
  }
}
