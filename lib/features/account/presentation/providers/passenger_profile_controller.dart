import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../../auth/presentation/providers/auth_dependencies.dart';
import '../../../auth/presentation/providers/auth_session_provider.dart';
import '../../domain/entities/passenger_profile.dart';
import '../../domain/passenger_profile_error_codes.dart';
import '../../domain/repositories/passenger_profile_repository.dart';
import 'passenger_profile_dependencies.dart';

class PassengerProfileState {
  const PassengerProfileState({
    this.profile,
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSaving = false,
    this.isUploadingAvatar = false,
    this.errorMessage,
    this.errorCode,
  });

  final PassengerProfile? profile;
  final bool isLoading;
  final bool isRefreshing;
  final bool isSaving;
  final bool isUploadingAvatar;
  final String? errorMessage;
  final String? errorCode;

  bool get isAccountDeactivated =>
      errorCode == PassengerProfileErrorCodes.accountDeactivated;

  PassengerProfileState copyWith({
    PassengerProfile? profile,
    bool? isLoading,
    bool? isRefreshing,
    bool? isSaving,
    bool? isUploadingAvatar,
    String? errorMessage,
    String? errorCode,
    bool clearProfile = false,
    bool clearError = false,
  }) {
    return PassengerProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSaving: isSaving ?? this.isSaving,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}

class PassengerProfileController extends Notifier<PassengerProfileState> {
  bool _loadInFlight = false;

  @override
  PassengerProfileState build() => const PassengerProfileState();

  @visibleForTesting
  void debugSeedState(PassengerProfileState next) {
    state = next;
  }

  void clear() {
    _loadInFlight = false;
    state = const PassengerProfileState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> loadIfNeeded() async {
    if (state.profile != null || state.isLoading || _loadInFlight) return;
    await refresh(initial: true);
  }

  Future<void> refresh({bool initial = false}) async {
    if (_loadInFlight) return;
    _loadInFlight = true;
    final hasProfile = state.profile != null;
    state = state.copyWith(
      isLoading: initial || !hasProfile,
      isRefreshing: hasProfile && !initial,
      clearError: true,
    );
    try {
      final profile = await ref
          .read(passengerProfileRepositoryProvider)
          .getProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
      );
    } catch (e) {
      _applyError(e, isLoading: false, isRefreshing: false);
    } finally {
      _loadInFlight = false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    PassengerProfilePhoneUpdate? phone,
  }) async {
    final previous = state.profile;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final profile = await ref
          .read(passengerProfileRepositoryProvider)
          .updateProfile(name: name, phone: phone);
      state = state.copyWith(
        profile: profile,
        isSaving: false,
        clearError: true,
      );
      if (name != null) {
        await _syncStoredDisplayName(profile.name);
      }
      return true;
    } catch (e) {
      state = state.copyWith(profile: previous, isSaving: false);
      _applyError(e, isSaving: false);
      return false;
    }
  }

  Future<bool> uploadAvatar({
    required String filePath,
    String? filename,
    String? mimeType,
  }) async {
    final previous = state.profile;
    state = state.copyWith(isUploadingAvatar: true, clearError: true);
    try {
      final profile = await ref
          .read(passengerProfileRepositoryProvider)
          .uploadAvatar(
            filePath: filePath,
            filename: filename,
            mimeType: mimeType,
          );
      state = state.copyWith(
        profile: profile,
        isUploadingAvatar: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(profile: previous, isUploadingAvatar: false);
      _applyError(e, isUploadingAvatar: false);
      return false;
    }
  }

  Future<bool> deleteAvatar() async {
    final previous = state.profile;
    state = state.copyWith(isUploadingAvatar: true, clearError: true);
    try {
      var profile = await ref
          .read(passengerProfileRepositoryProvider)
          .deleteAvatar();
      if (profile.profileImageUrl != null &&
          previous != null &&
          profile.profileImageUrl == previous.profileImageUrl) {
        profile = profile.copyWith(clearAvatar: true);
      } else if (profile.profileImageUrl == null) {
        profile = profile.copyWith(clearAvatar: true);
      }
      state = state.copyWith(
        profile: profile,
        isUploadingAvatar: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(profile: previous, isUploadingAvatar: false);
      _applyError(e, isUploadingAvatar: false);
      return false;
    }
  }

  Future<bool> deactivate({required bool confirm}) async {
    if (!confirm) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref
          .read(passengerProfileRepositoryProvider)
          .deactivate(confirm: true);
      state = state.copyWith(isSaving: false, clearError: true);
      return true;
    } catch (e) {
      _applyError(e, isSaving: false);
      return false;
    }
  }

  void _applyError(
    Object error, {
    bool? isLoading,
    bool? isRefreshing,
    bool? isSaving,
    bool? isUploadingAvatar,
  }) {
    String? code;
    var message = 'Something went wrong. Please try again.';
    if (error is PassengerApiException) {
      code = error.code;
      message = error.message;
      if (code == PassengerProfileErrorCodes.auth0Error) {
        message = PassengerProfileErrorCodes.auth0NameMessage;
      } else if (code == PassengerProfileErrorCodes.accountDeactivated) {
        message = PassengerProfileErrorCodes.deactivatedMessage;
      }
    } else if (error is FormatException) {
      message = 'Could not load your profile. Please try again.';
    }
    state = state.copyWith(
      isLoading: isLoading ?? state.isLoading,
      isRefreshing: isRefreshing ?? state.isRefreshing,
      isSaving: isSaving ?? state.isSaving,
      isUploadingAvatar: isUploadingAvatar ?? state.isUploadingAvatar,
      errorMessage: message,
      errorCode: code,
    );
  }

  Future<void> _syncStoredDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    try {
      await ref.read(authRepositoryProvider).updateStoredDisplayName(trimmed);
    } catch (_) {}
    ref.read(authSessionProvider.notifier).updateDisplayName(trimmed);
  }
}

final passengerProfileControllerProvider =
    NotifierProvider<PassengerProfileController, PassengerProfileState>(
      PassengerProfileController.new,
    );

