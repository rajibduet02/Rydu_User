import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/dio_provider.dart';
import '../../../app/providers/shared_preferences_provider.dart';
import '../../../app/router/app_router.dart';
import '../../../app/router/route_names.dart';
import '../../../core/device/passenger_device_identity.dart';
import '../../../core/network/passenger_api_error_mapper.dart';
import '../../../core/push/fcm_gateway.dart';
import '../../../core/push/notifications_preference_store.dart';
import '../../../core/push/passenger_firebase.dart';
import '../../../core/push/pending_ride_notification_store.dart';
import '../../../core/push/ride_push_dedupe.dart';
import '../../../core/push/ride_push_event.dart';
import '../../../core/push/ride_push_recovery.dart';
import '../../auth/presentation/providers/auth_session_provider.dart';
import '../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../domain/repositories/passenger_push_repository.dart';
import 'push_token_providers.dart';
import 'ride_push_actions.dart';

class PassengerPushState {
  const PassengerPushState({
    this.preferenceEnabled = true,
    this.osPermissionGranted = false,
    this.foregroundTrayShows = 0,
    this.userMessage,
    this.lastRecoveryAction,
    this.navigatedKeys = const [],
    this.registeredWithDeviceId,
  });

  final bool preferenceEnabled;
  final bool osPermissionGranted;
  final int foregroundTrayShows;
  final String? userMessage;
  final RidePushRecoveryAction? lastRecoveryAction;
  final List<String> navigatedKeys;
  final String? registeredWithDeviceId;

  bool get notificationsEnabled => preferenceEnabled && osPermissionGranted;

  PassengerPushState copyWith({
    bool? preferenceEnabled,
    bool? osPermissionGranted,
    int? foregroundTrayShows,
    String? userMessage,
    bool clearUserMessage = false,
    RidePushRecoveryAction? lastRecoveryAction,
    List<String>? navigatedKeys,
    String? registeredWithDeviceId,
    bool clearRegisteredDeviceId = false,
  }) {
    return PassengerPushState(
      preferenceEnabled: preferenceEnabled ?? this.preferenceEnabled,
      osPermissionGranted: osPermissionGranted ?? this.osPermissionGranted,
      foregroundTrayShows: foregroundTrayShows ?? this.foregroundTrayShows,
      userMessage: clearUserMessage
          ? null
          : (userMessage ?? this.userMessage),
      lastRecoveryAction: lastRecoveryAction ?? this.lastRecoveryAction,
      navigatedKeys: navigatedKeys ?? this.navigatedKeys,
      registeredWithDeviceId: clearRegisteredDeviceId
          ? null
          : (registeredWithDeviceId ?? this.registeredWithDeviceId),
    );
  }
}

final ridePushActionsProvider = Provider<RidePushActions>((ref) {
  return ProviderRidePushActions(ref);
});

final pendingRideNotificationStoreProvider =
    Provider<PendingRideNotificationStore>((ref) {
      return PendingRideNotificationStore();
    });

final notificationsPreferenceStoreProvider =
    Provider<NotificationsPreferenceStore>((ref) {
      return NotificationsPreferenceStore(
        ref.watch(sharedPreferencesProvider),
      );
    });

final fcmGatewayProvider = Provider<FcmGateway>((ref) {
  if (!passengerFirebaseReady) return const NoopFcmGateway();
  return FirebaseFcmGateway();
});

class PassengerPushController extends Notifier<PassengerPushState> {
  final RidePushDedupe _dedupe = RidePushDedupe();
  bool _surfaceReady = false;
  bool _listenersAttached = false;
  bool _recovering = false;
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RidePushMessage>? _foregroundSub;
  StreamSubscription<RidePushMessage>? _openedSub;

  @override
  PassengerPushState build() {
    ref.onDispose(() {
      unawaited(_tokenSub?.cancel());
      unawaited(_foregroundSub?.cancel());
      unawaited(_openedSub?.cancel());
    });
    final prefs = ref.watch(notificationsPreferenceStoreProvider);
    return PassengerPushState(preferenceEnabled: prefs.enabled);
  }

  FcmGateway get _fcm => ref.read(fcmGatewayProvider);
  PassengerPushRepository get _repo =>
      ref.read(passengerPushRepositoryProvider);
  PassengerDeviceIdentity get _device =>
      ref.read(passengerDeviceIdentityProvider);
  NotificationsPreferenceStore get _prefs =>
      ref.read(notificationsPreferenceStoreProvider);
  PendingRideNotificationStore get _pending =>
      ref.read(pendingRideNotificationStoreProvider);
  RidePushActions get _actions => ref.read(ridePushActionsProvider);

  bool get _isAuthenticated =>
      ref.read(authSessionProvider).isAuthenticated;

  bool get _onSplash {
    try {
      final loc = ref
          .read(goRouterProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .path;
      return loc == RouteNames.splash;
    } catch (_) {
      return true;
    }
  }

  Future<void> attachListeners() => _attachListeners();

  Future<void> _attachListeners() async {
    if (_listenersAttached) return;
    _listenersAttached = true;
    try {
      final fcm = _fcm;
      if (!fcm.isAvailable) return;
      await fcm.disableForegroundPresentation();
      _tokenSub = fcm.onTokenRefresh.listen(_onTokenRefresh);
      _foregroundSub = fcm.onForegroundMessage.listen(handleForegroundMessage);
      _openedSub = fcm.onMessageOpenedApp.listen(handleOpenedMessage);
      final initial = await fcm.getInitialMessage();
      if (initial != null) {
        handleOpenedMessage(initial, source: RidePushSource.coldStart);
      }
    } catch (_) {
      _listenersAttached = false;
    }
  }

  void handleForegroundMessage(RidePushMessage message) {
    final event = RidePushEvent.tryParse(
      message.data,
      source: RidePushSource.foreground,
    );
    if (event == null) {
      if (kDebugMode) {
        debugPrint('PassengerPush: ignore malformed/unknown foreground message');
      }
      return;
    }
    _dedupe.record(event.dedupeKey);
    if (kDebugMode) {
      debugPrint(
        'PassengerPush: foreground ${event.event.wireValue} '
        'bookingId=${event.bookingId} (socket owns UI, no tray)',
      );
    }
    // Intentionally no local notification and no navigation.
  }

  void handleOpenedMessage(
    RidePushMessage message, {
    RidePushSource source = RidePushSource.openedApp,
  }) {
    final event = RidePushEvent.tryParse(message.data, source: source);
    if (event == null) {
      if (kDebugMode) {
        debugPrint('PassengerPush: ignore malformed/unknown opened message');
      }
      return;
    }
    _pending.set(event);
    unawaited(processPendingTap());
  }

  /// Call after splash/home (or post-login) so cold-start taps wait for session.
  Future<void> onAuthenticatedSurfaceReady({
    bool requestPermissionIfNeeded = false,
  }) async {
    await _attachListeners();
    _surfaceReady = true;
    try {
      await syncToken(requestPermissionIfNeeded: requestPermissionIfNeeded);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('PassengerPush: token sync skipped');
      }
    }
    await processPendingTap();
  }

  Future<void> processPendingTap() async {
    if (!_surfaceReady || _onSplash) return;
    if (!_isAuthenticated) return;
    final event = _pending.take();
    if (event == null) return;
    await recoverFromTap(event);
  }

  Future<void> recoverFromTap(RidePushEvent event) async {
    if (_recovering) return;
    if (!_isAuthenticated) {
      _pending.set(event);
      return;
    }

    if (state.navigatedKeys.contains(event.dedupeKey)) {
      if (kDebugMode) {
        debugPrint(
          'PassengerPush: skip duplicate nav ${event.dedupeKey}',
        );
      }
      return;
    }

    _recovering = true;
    try {
      if (kDebugMode) {
        debugPrint(
          'PassengerPush: recover ${event.event.wireValue} '
          'bookingId=${event.bookingId} source=${event.source.name}',
        );
      }

      final localStale = isStaleRidePush(
        pushEvent: event.event,
        authoritativeStatus: _actions.currentStatus,
      );
      if (localStale &&
          _actions.currentBookingId == event.bookingId &&
          !event.isTerminalEvent) {
        await _hydrateById(event);
        return;
      }

      final start = RidePushRecovery.planTapStart(event);
      if (start.action == RidePushRecoveryAction.restoreActive) {
        final restored = await _actions.restoreActiveBooking(navigate: true);
        if (restored &&
            _actions.currentBookingId == event.bookingId &&
            _actions.hasActiveBooking) {
          _markNavigated(event, RidePushRecoveryAction.openLiveRide);
          return;
        }
        await _hydrateById(event);
        return;
      }
      if (start.action == RidePushRecoveryAction.loadBookingById) {
        await _hydrateById(event);
      }
    } catch (error) {
      if (error is PassengerApiException &&
          (error.code == 'ACCOUNT_DEACTIVATED' ||
              error.code == 'SESSION_INVALID')) {
        if (kDebugMode) {
          debugPrint('PassengerPush: skip recovery for invalid session');
        }
        return;
      }
      if (kDebugMode) {
        debugPrint('PassengerPush: recovery failed, opening activity');
      }
      _actions.openActivity(message: 'Could not open that ride.');
      state = state.copyWith(
        lastRecoveryAction: RidePushRecoveryAction.openActivity,
      );
    } finally {
      _recovering = false;
    }
  }

  Future<void> _hydrateById(RidePushEvent event) async {
    BookingEntity? booking;
    try {
      booking = await _actions.loadBookingById(event.bookingId);
    } on PassengerApiException catch (e) {
      if (e.statusCode == 404 || e.code == 'NOT_FOUND') {
        booking = null;
      } else {
        rethrow;
      }
    }

    final step = booking == null
        ? RidePushRecovery.afterBookingById(booking: null)
        : RidePushRecovery.reconcileWithAuthoritative(
            event: event,
            booking: booking,
          );

    switch (step.action) {
      case RidePushRecoveryAction.openLiveRide:
        final restored = await _actions.restoreActiveBooking(navigate: true);
        if (restored && _actions.hasActiveBooking) {
          _markNavigated(event, RidePushRecoveryAction.openLiveRide);
          return;
        }
        _actions.resumeActiveRide();
        _markNavigated(event, RidePushRecoveryAction.openLiveRide);
      case RidePushRecoveryAction.openRideDetails:
        _actions.openRideDetails(event.bookingId);
        _markNavigated(event, RidePushRecoveryAction.openRideDetails);
      case RidePushRecoveryAction.openActivity:
        _actions.openActivity(message: step.message);
        _markNavigated(event, RidePushRecoveryAction.openActivity);
      default:
        break;
    }
  }

  void _markNavigated(RidePushEvent event, RidePushRecoveryAction action) {
    _dedupe.record(event.dedupeKey);
    state = state.copyWith(
      lastRecoveryAction: action,
      navigatedKeys: [...state.navigatedKeys, event.dedupeKey],
    );
  }

  Future<void> _onTokenRefresh(String token) async {
    if (!_isAuthenticated) return;
    if (!_prefs.enabled) return;
    if (token.isEmpty) return;
    try {
      final deviceId = await _device.getOrCreate();
      await _repo.registerToken(token: token, deviceId: deviceId);
      state = state.copyWith(registeredWithDeviceId: deviceId);
      if (kDebugMode) {
        debugPrint('PassengerPush: token refresh re-registered deviceId=$deviceId');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('PassengerPush: token refresh register failed');
      }
    }
  }

  Future<void> syncToken({bool requestPermissionIfNeeded = false}) async {
    if (!_isAuthenticated) return;
    await _refreshPermissionState();
    if (!_prefs.enabled) {
      state = state.copyWith(preferenceEnabled: false);
      return;
    }
    var granted = state.osPermissionGranted;
    if (!granted && requestPermissionIfNeeded) {
      final perm = await _fcm.requestPermission();
      await _prefs.markOsPrompted();
      granted = perm == NotificationPermissionState.granted;
      state = state.copyWith(osPermissionGranted: granted);
    }
    if (!granted) {
      state = state.copyWith(
        preferenceEnabled: _prefs.enabled,
        osPermissionGranted: false,
      );
      return;
    }
    final token = await _fcm.getToken();
    if (token == null || token.isEmpty) return;
    final deviceId = await _device.getOrCreate();
    await _repo.registerToken(token: token, deviceId: deviceId);
    state = state.copyWith(
      preferenceEnabled: true,
      osPermissionGranted: true,
      registeredWithDeviceId: deviceId,
    );
    if (kDebugMode) {
      debugPrint('PassengerPush: registered deviceId=$deviceId');
    }
  }

  Future<void> _refreshPermissionState() async {
    final perm = await _fcm.currentPermission();
    state = state.copyWith(
      preferenceEnabled: _prefs.enabled,
      osPermissionGranted: perm == NotificationPermissionState.granted,
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      await _prefs.setEnabled(true);
      state = state.copyWith(preferenceEnabled: true);
      await syncToken(requestPermissionIfNeeded: true);
      if (!state.osPermissionGranted) {
        await _prefs.setEnabled(true);
      }
      return;
    }
    await _prefs.setEnabled(false);
    state = state.copyWith(preferenceEnabled: false);
    try {
      await _repo.unregisterToken();
      if (kDebugMode) {
        debugPrint('PassengerPush: unregistered (settings off)');
      }
    } catch (_) {
      if (kDebugMode) {
        debugPrint('PassengerPush: unregister on disable failed');
      }
    }
    state = state.copyWith(clearRegisteredDeviceId: true);
  }

  Future<void> refreshDisplayedPermission() => _refreshPermissionState();
}

final passengerPushControllerProvider =
    NotifierProvider<PassengerPushController, PassengerPushState>(
      PassengerPushController.new,
    );
