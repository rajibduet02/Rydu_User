import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'fcm_gateway.dart';
import 'ride_updates_channel.dart';

bool passengerFirebaseReady = false;

/// Minimal isolate handler. OS already displays notification+data payloads.
/// No navigation, no REST, no local notification.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // App must still work without Firebase config.
  }
}

/// Initializes Firebase if native config exists. Never throws to callers.
Future<bool> initializePassengerFirebase() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await ensureRideUpdatesChannel();
    passengerFirebaseReady = true;
    if (kDebugMode) {
      debugPrint('PassengerFirebase: initialized');
    }
    return true;
  } catch (error) {
    passengerFirebaseReady = false;
    if (kDebugMode) {
      debugPrint('PassengerFirebase: init skipped ($error)');
    }
    return false;
  }
}

class FirebaseFcmGateway implements FcmGateway {
  FirebaseFcmGateway();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  bool get isAvailable => passengerFirebaseReady;

  RidePushMessage _toMessage(RemoteMessage message) {
    return RidePushMessage(data: Map<String, dynamic>.from(message.data));
  }

  @override
  Future<String?> getToken() async {
    if (!isAvailable) return null;
    try {
      return await _messaging.getToken();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('PassengerFirebase: getToken failed');
      }
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh =>
      isAvailable ? _messaging.onTokenRefresh : const Stream.empty();

  @override
  Stream<RidePushMessage> get onForegroundMessage => isAvailable
      ? FirebaseMessaging.onMessage.map(_toMessage)
      : const Stream.empty();

  @override
  Stream<RidePushMessage> get onMessageOpenedApp => isAvailable
      ? FirebaseMessaging.onMessageOpenedApp.map(_toMessage)
      : const Stream.empty();

  @override
  Future<RidePushMessage?> getInitialMessage() async {
    if (!isAvailable) return null;
    try {
      final message = await _messaging.getInitialMessage();
      if (message == null) return null;
      return _toMessage(message);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<NotificationPermissionState> requestPermission() async {
    if (!isAvailable) return NotificationPermissionState.denied;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return _map(settings.authorizationStatus);
    } catch (_) {
      return NotificationPermissionState.denied;
    }
  }

  @override
  Future<NotificationPermissionState> currentPermission() async {
    if (!isAvailable) return NotificationPermissionState.denied;
    try {
      final settings = await _messaging.getNotificationSettings();
      return _map(settings.authorizationStatus);
    } catch (_) {
      return NotificationPermissionState.notDetermined;
    }
  }

  @override
  Future<void> disableForegroundPresentation() async {
    if (!isAvailable) return;
    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    } catch (_) {}
  }

  NotificationPermissionState _map(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized ||
      AuthorizationStatus.provisional => NotificationPermissionState.granted,
      AuthorizationStatus.denied => NotificationPermissionState.denied,
      AuthorizationStatus.notDetermined =>
        NotificationPermissionState.notDetermined,
    };
  }
}
