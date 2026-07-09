import '../../domain/entities/user_entity.dart';

/// Application authentication session status.
enum AuthSessionStatus {
  /// Session restore in progress (splash / cold start).
  loading,

  /// Valid backend session present.
  authenticated,

  /// No valid session.
  unauthenticated,
}

/// Immutable auth session state exposed to routing and UI providers.
class AuthSessionState {
  const AuthSessionState({required this.status, this.user});

  const AuthSessionState.loading() : this(status: AuthSessionStatus.loading);

  const AuthSessionState.unauthenticated()
    : this(status: AuthSessionStatus.unauthenticated);

  AuthSessionState.authenticated(UserEntity user)
    : this(status: AuthSessionStatus.authenticated, user: user);

  final AuthSessionStatus status;
  final UserEntity? user;

  bool get isLoading => status == AuthSessionStatus.loading;
  bool get isAuthenticated => status == AuthSessionStatus.authenticated;
  bool get isUnauthenticated => status == AuthSessionStatus.unauthenticated;

  AuthSessionState copyWith({
    AuthSessionStatus? status,
    UserEntity? user,
    bool clearUser = false,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
    );
  }
}
