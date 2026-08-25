import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rydu_user/app/router/app_router.dart';
import 'package:rydu_user/app/router/route_names.dart';
import 'package:rydu_user/core/network/passenger_api_error_mapper.dart';
import 'package:rydu_user/core/network/passenger_socket_service.dart';
import 'package:rydu_user/core/storage/secure_storage_service.dart';
import 'package:rydu_user/features/account/domain/entities/passenger_profile.dart';
import 'package:rydu_user/features/account/domain/passenger_profile_error_codes.dart';
import 'package:rydu_user/features/account/domain/repositories/passenger_profile_repository.dart';
import 'package:rydu_user/features/account/presentation/providers/account_controller.dart';
import 'package:rydu_user/features/account/presentation/providers/passenger_profile_controller.dart';
import 'package:rydu_user/features/account/presentation/providers/passenger_profile_dependencies.dart';
import 'package:rydu_user/features/account/presentation/screens/account_screen.dart';
import 'package:rydu_user/features/account/presentation/screens/profile_details_screen.dart';
import 'package:rydu_user/features/account/presentation/widgets/account_header.dart';
import 'package:rydu_user/features/account/presentation/widgets/deactivate_account_dialog.dart';
import 'package:rydu_user/features/auth/domain/entities/user_entity.dart';
import 'package:rydu_user/features/auth/domain/repositories/auth_repository.dart';
import 'package:rydu_user/features/auth/domain/usecases/logout_usecase.dart';
import 'package:rydu_user/features/auth/presentation/providers/auth_dependencies.dart';
import 'package:rydu_user/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';

const _profile = PassengerProfile(
  id: 'user-1',
  name: 'Test Passenger',
  email: 'test@example.com',
  phone: '+14155550123',
  accountStatus: 'active',
);

const _profileWithAvatar = PassengerProfile(
  id: 'user-1',
  name: 'Test Passenger',
  email: 'test@example.com',
  phone: '+14155550123',
  profileImageUrl: '/uploads/avatars/passengers/x.jpg',
  accountStatus: 'active',
);

class _FakeProfileRepo implements PassengerProfileRepository {
  _FakeProfileRepo({PassengerProfile? profile}) : current = profile ?? _profile;

  PassengerProfile current;
  Object? error;
  Map<String, dynamic>? lastPatch;
  bool avatarDeleted = false;
  bool deactivated = false;
  bool confirmValue = false;

  @override
  Future<PassengerProfile> getProfile() async {
    if (error != null) throw error!;
    return current;
  }

  @override
  Future<PassengerProfile> updateProfile({
    String? name,
    PassengerProfilePhoneUpdate? phone,
  }) async {
    lastPatch = <String, dynamic>{};
    if (name != null) {
      lastPatch!['name'] = name;
    }
    if (phone != null) {
      lastPatch!['phone'] = phone.clear
          ? null
          : {'countryCode': phone.countryCode, 'number': phone.number};
    }
    if (error != null) throw error!;
    current = current.copyWith(
      name: name ?? current.name,
      phone: phone == null
          ? current.phone
          : (phone.clear ? null : '${phone.countryCode}${phone.number}'),
      clearPhone: phone?.clear ?? false,
    );
    return current;
  }

  @override
  Future<PassengerProfile> uploadAvatar({
    required String filePath,
    String? filename,
    String? mimeType,
  }) async {
    if (error != null) throw error!;
    current = current.copyWith(
      profileImageUrl: '/uploads/avatars/passengers/new.jpg',
    );
    return current;
  }

  @override
  Future<PassengerProfile> deleteAvatar() async {
    if (error != null) throw error!;
    avatarDeleted = true;
    current = current.copyWith(clearAvatar: true);
    return current;
  }

  @override
  Future<void> deactivate({required bool confirm}) async {
    if (error != null) throw error!;
    confirmValue = confirm;
    deactivated = true;
  }
}

class _FakeAuthRepo implements AuthRepository {
  bool signedOut = false;
  String? storedName;

  @override
  Future<UserEntity> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {}

  @override
  Future<bool> hasValidSession() async => false;

  @override
  Future<UserEntity?> getCurrentUser() async => null;

  @override
  Future<UserEntity?> getMe() async => null;

  @override
  Future<void> sendOtp({required String phone}) async {}

  @override
  Future<void> verifyOtp({
    required String phone,
    required String code,
  }) async {}

  @override
  Future<String> requestPasswordReset({required String email}) async => '';

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Future<void> signInWithPhone({
    required String fullPhone,
    required String password,
  }) async {}

  @override
  Future<void> registerWithPhone({
    required String fullName,
    required String fullPhone,
    required String password,
  }) async {}

  @override
  Future<void> sendPasswordResetOtp({required String fullPhone}) async {}

  @override
  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {}

  @override
  Future<void> updateStoredDisplayName(String name) async {
    storedName = name;
  }
}

class _TrackingSocket extends PassengerSocketService {
  _TrackingSocket() : super(SecureStorageService());

  int disconnects = 0;

  @override
  Future<void> disconnect({bool preserveActiveBooking = false}) async {
    disconnects++;
  }
}

ProviderContainer _container({
  required _FakeProfileRepo profile,
  _FakeAuthRepo? auth,
  _TrackingSocket? socket,
  GoRouter? router,
}) {
  final authRepo = auth ?? _FakeAuthRepo();
  final goRouter =
      router ??
      GoRouter(
        initialLocation: RouteNames.account,
        routes: [
          GoRoute(
            path: RouteNames.account,
            builder: (_, _) => const AccountScreen(),
          ),
          GoRoute(
            path: RouteNames.profileDetails,
            builder: (_, _) => const ProfileDetailsScreen(),
          ),
          GoRoute(
            path: RouteNames.editProfile,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.rideHistory,
            builder: (_, _) => const Text('Ride History Page'),
          ),
          GoRoute(path: RouteNames.auth, builder: (_, _) => const Text('Auth')),
          GoRoute(path: RouteNames.home, builder: (_, _) => const SizedBox()),
          GoRoute(
            path: RouteNames.wallet,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.helpCenter,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.safetyCenter,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.inbox,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.savedPlaces,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.businessTravel,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.family,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.membership,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.security,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.privacyAndData,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.services,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.activity,
            builder: (_, _) => const SizedBox(),
          ),
        ],
      );

  return ProviderContainer(
    overrides: [
      passengerProfileRepositoryProvider.overrideWithValue(profile),
      authRepositoryProvider.overrideWithValue(authRepo),
      logoutUsecaseProvider.overrideWithValue(LogoutUsecase(authRepo)),
      passengerSocketServiceProvider.overrideWithValue(
        socket ?? _TrackingSocket(),
      ),
      goRouterProvider.overrideWithValue(goRouter),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('4-5. default profile state has no demo identities', () {
    const state = PassengerProfileState();
    expect(state.profile, isNull);
    expect(state.profile?.name, isNot(contains('Mir Efaj')));
    expect(state.profile?.name, isNot(contains('Afshara Tasnim')));
  });

  testWidgets('2. Account header uses real profile', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccountHeader(
            profile: _profile,
            isUploadingAvatar: false,
            onAvatarTap: _noop,
            onEditProfile: _noop,
          ),
        ),
      ),
    );
    expect(find.text('Test Passenger'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('+14155550123'), findsOneWidget);
    expect(find.text('Mir Efaj'), findsNothing);
    expect(find.text('Afshara Tasnim'), findsNothing);
    expect(find.text('5.0'), findsNothing);
    expect(find.textContaining('RYD U One'), findsNothing);
  });

  testWidgets('3. Profile Details uses same profile', (tester) async {
    final repo = _FakeProfileRepo();
    final container = _container(profile: repo);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfileDetailsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Passenger'), findsWidgets);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('+14155550123'), findsOneWidget);
    expect(find.text('Verified'), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    expect(find.text('Mir Efaj'), findsNothing);
    expect(find.text('Afshara Tasnim'), findsNothing);
  });

  testWidgets('6. No fake phone verified badge on Account', (tester) async {
    final repo = _FakeProfileRepo();
    final container = _container(profile: repo);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Passenger'), findsOneWidget);
    expect(find.text('127 rides'), findsNothing);
    expect(find.text('BDT 250.00'), findsNothing);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  test('11. AUTH0_ERROR leaves old profile', () async {
    final repo = _FakeProfileRepo();
    final container = _container(profile: repo);
    addTearDown(container.dispose);
    await container.read(passengerProfileControllerProvider.notifier).refresh();
    repo.error = const PassengerApiException(
      'Auth0 failed',
      code: PassengerProfileErrorCodes.auth0Error,
    );
    final ok = await container
        .read(passengerProfileControllerProvider.notifier)
        .updateProfile(name: 'New Name');
    expect(ok, isFalse);
    final state = container.read(passengerProfileControllerProvider);
    expect(state.profile?.name, 'Test Passenger');
    expect(state.errorMessage, PassengerProfileErrorCodes.auth0NameMessage);
  });

  test('14. Avatar success updates shared profile', () async {
    final repo = _FakeProfileRepo(
      profile: _profile.copyWith(clearAvatar: true),
    );
    final container = _container(profile: repo);
    addTearDown(container.dispose);
    await container.read(passengerProfileControllerProvider.notifier).refresh();
    final ok = await container
        .read(passengerProfileControllerProvider.notifier)
        .uploadAvatar(filePath: '/tmp/a.jpg', filename: 'a.jpg');
    expect(ok, isTrue);
    expect(
      container.read(passengerProfileControllerProvider).profile?.profileImageUrl,
      '/uploads/avatars/passengers/new.jpg',
    );
  });

  test('15. Avatar delete fallback', () async {
    final repo = _FakeProfileRepo(profile: _profileWithAvatar);
    final container = _container(profile: repo);
    addTearDown(container.dispose);
    await container.read(passengerProfileControllerProvider.notifier).refresh();
    final ok = await container
        .read(passengerProfileControllerProvider.notifier)
        .deleteAvatar();
    expect(ok, isTrue);
    expect(repo.avatarDeleted, isTrue);
    expect(
      container.read(passengerProfileControllerProvider).profile?.profileImageUrl,
      isNull,
    );
  });

  test('16-17. Logout clears profile to empty and disconnects socket', () async {
    final repo = _FakeProfileRepo();
    final auth = _FakeAuthRepo();
    final socket = _TrackingSocket();
    final container = _container(profile: repo, auth: auth, socket: socket);
    addTearDown(container.dispose);
    await container.read(passengerProfileControllerProvider.notifier).refresh();
    expect(container.read(passengerProfileControllerProvider).profile, isNotNull);
    await container.read(accountControllerProvider.notifier).logout();
    expect(auth.signedOut, isTrue);
    expect(socket.disconnects, 1);
    expect(container.read(passengerProfileControllerProvider).profile, isNull);
    expect(container.read(authSessionProvider).isUnauthenticated, isTrue);
    expect(
      container.read(passengerProfileControllerProvider).profile?.name,
      isNot(equals('Mir Efaj')),
    );
  });

  testWidgets('18. Deactivate confirmation copy', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: DeactivateAccountDialog())),
      ),
    );
    expect(find.text('Deactivate account?'), findsOneWidget);
    expect(
      find.textContaining('Your account will be deactivated'),
      findsOneWidget,
    );
    expect(find.text('Deactivate'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  test('19. Active ride blocks deactivate', () async {
    final repo = _FakeProfileRepo();
    final container = _container(profile: repo);
    addTearDown(container.dispose);
    container
        .read(rideBookingControllerProvider.notifier)
        .debugSeedState(
          const RideBookingState(
            bookingId: 'active-1',
            bookingStatus: 'accepted',
            phase: RidePlanningPhase.driverAccepted,
          ),
        );
    final ok = await container
        .read(accountControllerProvider.notifier)
        .deactivateAccount();
    expect(ok, isFalse);
    expect(repo.deactivated, isFalse);
    expect(
      container.read(accountControllerProvider).errorMessage,
      PassengerProfileErrorCodes.activeRideBlocksDeactivate,
    );
  });

  test('20. Deactivate success reuses logout', () async {
    final repo = _FakeProfileRepo();
    final auth = _FakeAuthRepo();
    final socket = _TrackingSocket();
    final container = _container(profile: repo, auth: auth, socket: socket);
    addTearDown(container.dispose);
    await container.read(passengerProfileControllerProvider.notifier).refresh();
    final ok = await container
        .read(accountControllerProvider.notifier)
        .deactivateAccount();
    expect(ok, isTrue);
    expect(repo.deactivated, isTrue);
    expect(repo.confirmValue, isTrue);
    expect(auth.signedOut, isTrue);
    expect(socket.disconnects, 1);
    expect(container.read(passengerProfileControllerProvider).profile, isNull);
  });

  test('21. ACCOUNT_DEACTIVATED handled on profile load', () async {
    final repo = _FakeProfileRepo()
      ..error = const PassengerApiException(
        'gone',
        code: PassengerProfileErrorCodes.accountDeactivated,
        statusCode: 403,
      );
    final container = _container(profile: repo);
    addTearDown(container.dispose);
    await container.read(passengerProfileControllerProvider.notifier).refresh();
    final state = container.read(passengerProfileControllerProvider);
    expect(state.isAccountDeactivated, isTrue);
    expect(state.errorMessage, PassengerProfileErrorCodes.deactivatedMessage);
  });

  test('VALIDATION_ERROR is not treated as logout', () async {
    final repo = _FakeProfileRepo();
    final auth = _FakeAuthRepo();
    final container = _container(profile: repo, auth: auth);
    addTearDown(container.dispose);
    await container.read(passengerProfileControllerProvider.notifier).refresh();
    repo.error = const PassengerApiException(
      'Invalid phone',
      code: PassengerProfileErrorCodes.validationError,
      statusCode: 400,
    );
    await container
        .read(passengerProfileControllerProvider.notifier)
        .updateProfile(
          phone: const PassengerProfilePhoneUpdate.set(
            countryCode: '+1',
            number: '1',
          ),
        );
    expect(auth.signedOut, isFalse);
    expect(
      container.read(passengerProfileControllerProvider).isAccountDeactivated,
      isFalse,
    );
    expect(
      container.read(passengerProfileControllerProvider).profile?.name,
      'Test Passenger',
    );
  });

  testWidgets('22. Ride History navigation unchanged', (tester) async {
    final repo = _FakeProfileRepo();
    final container = _container(profile: repo);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: container.read(goRouterProvider),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ride History'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Ride History'));
    await tester.pumpAndSettle();
    expect(find.text('Ride History Page'), findsOneWidget);
  });

  test('session displayName updates after name PATCH', () async {
    final repo = _FakeProfileRepo();
    final auth = _FakeAuthRepo();
    final container = _container(profile: repo, auth: auth);
    addTearDown(container.dispose);
    container
        .read(authSessionProvider.notifier)
        .markAuthenticated(
          const UserEntity(
            id: 'user-1',
            email: 'test@example.com',
            displayName: 'Test Passenger',
          ),
        );
    await container.read(passengerProfileControllerProvider.notifier).refresh();
    await container
        .read(passengerProfileControllerProvider.notifier)
        .updateProfile(name: 'Ada Lovelace');
    expect(auth.storedName, 'Ada Lovelace');
    expect(
      container.read(authSessionProvider).user?.displayName,
      'Ada Lovelace',
    );
    expect(container.read(authSessionProvider).user?.email, 'test@example.com');
    expect(container.read(authSessionProvider).user?.id, 'user-1');
  });
}

void _noop() {}
