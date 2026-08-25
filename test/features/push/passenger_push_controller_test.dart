import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rydu_user/app/providers/dio_provider.dart';
import 'package:rydu_user/app/providers/shared_preferences_provider.dart';
import 'package:rydu_user/app/router/app_router.dart';
import 'package:rydu_user/app/router/route_names.dart';
import 'package:rydu_user/core/device/passenger_device_identity.dart';
import 'package:rydu_user/core/push/fcm_gateway.dart';
import 'package:rydu_user/core/push/ride_push_event.dart';
import 'package:rydu_user/core/push/ride_push_recovery.dart';
import 'package:rydu_user/features/auth/domain/entities/user_entity.dart';
import 'package:rydu_user/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rydu_user/features/auth/presentation/state/auth_session_state.dart';
import 'package:rydu_user/features/push/domain/repositories/passenger_push_repository.dart';
import 'package:rydu_user/features/push/presentation/passenger_push_controller.dart';
import 'package:rydu_user/features/push/presentation/push_token_providers.dart';
import 'package:rydu_user/features/push/presentation/ride_push_actions.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFcm implements FcmGateway {
  _FakeFcm();

  String? token = 'fcm-token';
  NotificationPermissionState permission = NotificationPermissionState.granted;
  RidePushMessage? initial;
  final tokenRefresh = StreamController<String>.broadcast();
  final foreground = StreamController<RidePushMessage>.broadcast();
  final opened = StreamController<RidePushMessage>.broadcast();
  int requestPermissionCalls = 0;
  int localNotificationShows = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<void> disableForegroundPresentation() async {}

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => tokenRefresh.stream;

  @override
  Stream<RidePushMessage> get onForegroundMessage => foreground.stream;

  @override
  Stream<RidePushMessage> get onMessageOpenedApp => opened.stream;

  @override
  Future<RidePushMessage?> getInitialMessage() async => initial;

  @override
  Future<NotificationPermissionState> requestPermission() async {
    requestPermissionCalls++;
    return permission;
  }

  @override
  Future<NotificationPermissionState> currentPermission() async => permission;
}

class _FakePushRepo implements PassengerPushRepository {
  String? lastToken;
  String? lastDeviceId;
  int registerCalls = 0;
  int unregisterCalls = 0;

  @override
  Future<void> registerToken({
    required String token,
    required String deviceId,
  }) async {
    registerCalls++;
    lastToken = token;
    lastDeviceId = deviceId;
  }

  @override
  Future<void> unregisterToken() async {
    unregisterCalls++;
  }
}

class _FakeActions implements RidePushActions {
  BookingEntity? active;
  BookingEntity? byId;
  @override
  String? currentBookingId;
  @override
  String? currentStatus;
  @override
  bool hasActiveBooking = false;

  int restoreCalls = 0;
  bool? lastRestoreNavigate;
  final loads = <String>[];
  final details = <String>[];
  int resumeCalls = 0;
  int activityCalls = 0;

  @override
  Future<bool> restoreActiveBooking({required bool navigate}) async {
    restoreCalls++;
    lastRestoreNavigate = navigate;
    if (active == null || !active!.isActive) return false;
    currentBookingId = active!.id;
    currentStatus = active!.status;
    hasActiveBooking = true;
    return true;
  }

  @override
  Future<BookingEntity?> loadBookingById(String bookingId) async {
    loads.add(bookingId);
    if (byId != null && byId!.id == bookingId) return byId;
    return null;
  }

  @override
  void resumeActiveRide() {
    resumeCalls++;
  }

  @override
  void openRideDetails(String bookingId) {
    details.add(bookingId);
  }

  @override
  void openActivity({String? message}) {
    activityCalls++;
  }
}

class _Auth extends AuthSessionNotifier {
  _Auth({this.authenticated = true});

  final bool authenticated;

  @override
  AuthSessionState build() {
    if (!authenticated) return const AuthSessionState.unauthenticated();
    return AuthSessionState.authenticated(
      const UserEntity(id: 'u1', email: 'a@b.com'),
    );
  }
}

RidePushMessage _msg(String event, {String id = 'b1'}) {
  return RidePushMessage(
    data: {'type': 'ride_event', 'bookingId': id, 'event': event},
  );
}

ProviderContainer _container({
  required SharedPreferences prefs,
  required _FakeFcm fcm,
  required _FakePushRepo repo,
  required _FakeActions actions,
  bool authenticated = true,
}) {
  final identity = PassengerDeviceIdentity(
    prefs,
    generateId: () => 'device-stable',
  );
  final router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (_, _) => const SizedBox(),
      ),
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) => const SizedBox(),
      ),
      GoRoute(
        path: RouteNames.activity,
        builder: (_, _) => const SizedBox(),
      ),
      GoRoute(
        path: RouteNames.rideDetails,
        builder: (_, _) => const SizedBox(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (_, _) => const SizedBox(),
      ),
    ],
  );
  return ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      passengerDeviceIdentityProvider.overrideWithValue(identity),
      fcmGatewayProvider.overrideWithValue(fcm),
      passengerPushRepositoryProvider.overrideWithValue(repo),
      ridePushActionsProvider.overrideWithValue(actions),
      goRouterProvider.overrideWithValue(router),
      authSessionProvider.overrideWith(
        () => _Auth(authenticated: authenticated),
      ),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('token register uses same device ID', () async {
    final prefs = await SharedPreferences.getInstance();
    final fcm = _FakeFcm();
    final repo = _FakePushRepo();
    final actions = _FakeActions();
    final container = _container(
      prefs: prefs,
      fcm: fcm,
      repo: repo,
      actions: actions,
    );
    addTearDown(container.dispose);

    await container
        .read(passengerPushControllerProvider.notifier)
        .onAuthenticatedSurfaceReady();

    expect(repo.registerCalls, 1);
    expect(repo.lastDeviceId, 'device-stable');
    expect(
      container.read(passengerPushControllerProvider).registeredWithDeviceId,
      'device-stable',
    );
  });

  test('token refresh re-registers', () async {
    final prefs = await SharedPreferences.getInstance();
    final fcm = _FakeFcm();
    final repo = _FakePushRepo();
    final container = _container(
      prefs: prefs,
      fcm: fcm,
      repo: repo,
      actions: _FakeActions(),
    );
    addTearDown(container.dispose);

    container.read(passengerPushControllerProvider);
    await container
        .read(passengerPushControllerProvider.notifier)
        .onAuthenticatedSurfaceReady();
    expect(repo.registerCalls, 1);
    fcm.tokenRefresh.add('rotated-token');
    await Future<void>.delayed(Duration.zero);

    expect(repo.registerCalls, 2);
    expect(repo.lastToken, 'rotated-token');
    expect(repo.lastDeviceId, 'device-stable');
  });

  test('foreground ride FCM does not create duplicate tray notification', () async {
    final prefs = await SharedPreferences.getInstance();
    final fcm = _FakeFcm();
    final actions = _FakeActions()
      ..active = const BookingEntity(id: 'b1', status: 'arrived');
    final container = _container(
      prefs: prefs,
      fcm: fcm,
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);

    final c = container.read(passengerPushControllerProvider.notifier);
    c.handleForegroundMessage(_msg('arrived'));

    expect(container.read(passengerPushControllerProvider).foregroundTrayShows, 0);
    expect(fcm.localNotificationShows, 0);
    expect(actions.restoreCalls, 0);
    expect(actions.details, isEmpty);
  });

  test('background tap hydrates before navigation', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..active = const BookingEntity(id: 'b1', status: 'arrived');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);

    final c = container.read(passengerPushControllerProvider.notifier);
    await c.onAuthenticatedSurfaceReady();
    await c.recoverFromTap(
      RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'b1',
        'event': 'arrived',
      })!,
    );

    expect(actions.restoreCalls, 1);
    expect(actions.lastRestoreNavigate, isTrue);
    expect(actions.restoreCalls >= actions.details.length, isTrue);
  });

  test('cold-start tap waits for session restore', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..active = const BookingEntity(id: 'b1', status: 'in_progress');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
      authenticated: false,
    );
    addTearDown(container.dispose);

    final c = container.read(passengerPushControllerProvider.notifier);
    c.handleOpenedMessage(
      _msg('in_progress'),
      source: RidePushSource.coldStart,
    );
    await c.processPendingTap();
    expect(actions.restoreCalls, 0);

    // Surface ready while still unauthenticated must not hydrate.
    await c.onAuthenticatedSurfaceReady();
    expect(actions.restoreCalls, 0);
  });

  test('active event calls active booking restore', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..active = const BookingEntity(id: 'b1', status: 'driver_en_route');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);
    final c = container.read(passengerPushControllerProvider.notifier);
    await c.onAuthenticatedSurfaceReady();
    await c.recoverFromTap(
      RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'b1',
        'event': 'driver_en_route',
      })!,
    );
    expect(actions.restoreCalls, 1);
  });

  test('active-null falls back to bookingById', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..active = null
      ..byId = const BookingEntity(id: 'b1', status: 'completed');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);
    final c = container.read(passengerPushControllerProvider.notifier);
    await c.onAuthenticatedSurfaceReady();
    await c.recoverFromTap(
      RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'b1',
        'event': 'arrived',
      })!,
    );
    expect(actions.restoreCalls, 1);
    expect(actions.loads, ['b1']);
    expect(actions.details, ['b1']);
  });

  test('completed tap loads bookingById', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..byId = const BookingEntity(id: 'b1', status: 'completed');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);
    await container
        .read(passengerPushControllerProvider.notifier)
        .onAuthenticatedSurfaceReady();
    await container.read(passengerPushControllerProvider.notifier).recoverFromTap(
      RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'b1',
        'event': 'completed',
      })!,
    );
    expect(actions.loads, ['b1']);
    expect(actions.details, ['b1']);
    expect(actions.restoreCalls, 0);
  });

  test('cancelled tap loads bookingById', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..byId = const BookingEntity(id: 'b1', status: 'cancelled');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);
    final c = container.read(passengerPushControllerProvider.notifier);
    await c.onAuthenticatedSurfaceReady();
    await c.recoverFromTap(
      RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'b1',
        'event': 'cancelled',
      })!,
    );
    expect(actions.loads, ['b1']);
    expect(actions.details, ['b1']);
  });

  test('no_drivers tap loads bookingById', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..byId = const BookingEntity(id: 'b1', status: 'no_drivers');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);
    final c = container.read(passengerPushControllerProvider.notifier);
    await c.onAuthenticatedSurfaceReady();
    await c.recoverFromTap(
      RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'b1',
        'event': 'no_drivers',
      })!,
    );
    expect(actions.loads, ['b1']);
    expect(actions.details, ['b1']);
  });

  test('stale en-route cannot override later REST completed', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..currentBookingId = 'b1'
      ..currentStatus = 'completed'
      ..byId = const BookingEntity(id: 'b1', status: 'completed');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);
    final c = container.read(passengerPushControllerProvider.notifier);
    await c.onAuthenticatedSurfaceReady();
    await c.recoverFromTap(
      RidePushEvent.tryParse({
        'type': 'ride_event',
        'bookingId': 'b1',
        'event': 'driver_en_route',
      })!,
    );
    expect(actions.details, ['b1']);
    expect(actions.hasActiveBooking, isFalse);
  });

  test('duplicate bookingId+event does not navigate twice', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..active = const BookingEntity(id: 'b1', status: 'arrived');
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);
    final c = container.read(passengerPushControllerProvider.notifier);
    await c.onAuthenticatedSurfaceReady();
    final event = RidePushEvent.tryParse({
      'type': 'ride_event',
      'bookingId': 'b1',
      'event': 'arrived',
    })!;
    await c.recoverFromTap(event);
    await c.recoverFromTap(event);
    expect(actions.restoreCalls, 1);
    expect(
      container.read(passengerPushControllerProvider).lastRecoveryAction,
      RidePushRecoveryAction.openLiveRide,
    );
  });

  test('Socket foreground event remains authoritative', () async {
    final prefs = await SharedPreferences.getInstance();
    final actions = _FakeActions()
      ..currentBookingId = 'b1'
      ..currentStatus = 'arrived'
      ..hasActiveBooking = true;
    final container = _container(
      prefs: prefs,
      fcm: _FakeFcm(),
      repo: _FakePushRepo(),
      actions: actions,
    );
    addTearDown(container.dispose);
    container.read(passengerPushControllerProvider.notifier).handleForegroundMessage(
      _msg('arrived'),
    );
    expect(actions.restoreCalls, 0);
    expect(actions.details, isEmpty);
    expect(actions.resumeCalls, 0);
  });
}
