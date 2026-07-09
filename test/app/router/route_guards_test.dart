import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/app/router/route_guards.dart';
import 'package:rydu_user/app/router/route_names.dart';
import 'package:rydu_user/features/auth/domain/entities/user_entity.dart';
import 'package:rydu_user/features/auth/presentation/state/auth_session_state.dart';

void main() {
  group('RouteGuards', () {
    test('loading session keeps user on splash', () {
      expect(
        RouteGuards.redirectForLocation(
          const AuthSessionState.loading(),
          RouteNames.splash,
        ),
        isNull,
      );
    });

    test('loading session allows auth during splash handoff', () {
      expect(
        RouteGuards.redirectForLocation(
          const AuthSessionState.loading(),
          RouteNames.auth,
        ),
        isNull,
      );
    });

    test('loading session redirects other routes to splash', () {
      expect(
        RouteGuards.redirectForLocation(
          const AuthSessionState.loading(),
          RouteNames.home,
        ),
        RouteNames.splash,
      );
    });

    test('authenticated user on auth screen goes home', () {
      expect(
        RouteGuards.redirectForLocation(
          AuthSessionState.authenticated(
            const UserEntity(id: '1', email: 'a@b.com'),
          ),
          RouteNames.auth,
        ),
        RouteNames.home,
      );
    });

    test('unauthenticated user on protected route goes to auth', () {
      expect(
        RouteGuards.redirectForLocation(
          const AuthSessionState.unauthenticated(),
          RouteNames.wallet,
        ),
        RouteNames.auth,
      );
    });

    test('unauthenticated user can access register', () {
      expect(
        RouteGuards.redirectForLocation(
          const AuthSessionState.unauthenticated(),
          RouteNames.register,
        ),
        isNull,
      );
    });
  });
}
