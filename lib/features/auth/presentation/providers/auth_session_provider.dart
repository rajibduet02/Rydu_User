import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../state/auth_session_state.dart';
import 'auth_dependencies.dart';

/// Central auth/session state for routing and post-login updates.
class AuthSessionNotifier extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() => const AuthSessionState.loading();

  /// Restores session from secure storage on cold start.
  Future<void> restore() async {
    state = const AuthSessionState.loading();
    try {
      final hasSession = await ref
          .read(restoreSessionUsecaseProvider)
          .call()
          .timeout(const Duration(seconds: 4));
      if (!hasSession) {
        state = const AuthSessionState.unauthenticated();
        return;
      }
      final user = await ref
          .read(getCurrentUserUsecaseProvider)
          .call()
          .timeout(const Duration(seconds: 4));
      if (user != null) {
        state = AuthSessionState.authenticated(user);
      } else {
        state = const AuthSessionState.unauthenticated();
      }
    } catch (_) {
      state = const AuthSessionState.unauthenticated();
    }
  }

  void markAuthenticated(UserEntity user) {
    state = AuthSessionState.authenticated(user);
  }

  void markUnauthenticated() {
    state = const AuthSessionState.unauthenticated();
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );
