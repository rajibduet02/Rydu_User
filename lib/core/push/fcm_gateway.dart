enum NotificationPermissionState { granted, denied, notDetermined }

/// Abstraction over Firebase Cloud Messaging so tests do not need Firebase.
abstract interface class FcmGateway {
  bool get isAvailable;

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Stream<RidePushMessage> get onForegroundMessage;

  Stream<RidePushMessage> get onMessageOpenedApp;

  Future<RidePushMessage?> getInitialMessage();

  Future<NotificationPermissionState> requestPermission();

  Future<NotificationPermissionState> currentPermission();

  /// iOS: hide system presentation while foreground so Socket remains UI owner.
  Future<void> disableForegroundPresentation();
}

class RidePushMessage {
  const RidePushMessage({required this.data});

  final Map<String, dynamic> data;
}

class NoopFcmGateway implements FcmGateway {
  const NoopFcmGateway();

  @override
  bool get isAvailable => false;

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<RidePushMessage> get onForegroundMessage => const Stream.empty();

  @override
  Stream<RidePushMessage> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<RidePushMessage?> getInitialMessage() async => null;

  @override
  Future<NotificationPermissionState> requestPermission() async =>
      NotificationPermissionState.denied;

  @override
  Future<NotificationPermissionState> currentPermission() async =>
      NotificationPermissionState.denied;

  @override
  Future<void> disableForegroundPresentation() async {}
}
