import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Android channel used by backend FCM `android.notification.channelId`.
abstract final class RideUpdatesChannel {
  static const id = 'ride_updates';
  static const name = 'Ride updates';
  static const description = 'Updates about your current ride';

  static const importance = Importance.high;
}

/// Creates the `ride_updates` channel. Does not display notifications.
Future<void> ensureRideUpdatesChannel({
  FlutterLocalNotificationsPlugin? plugin,
}) async {
  try {
    final notifications = plugin ?? FlutterLocalNotificationsPlugin();
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await notifications.initialize(settings: init);
    final android = notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        RideUpdatesChannel.id,
        RideUpdatesChannel.name,
        description: RideUpdatesChannel.description,
        importance: Importance.high,
      ),
    );
  } catch (error) {
    if (kDebugMode) {
      debugPrint('RideUpdatesChannel: create skipped ($error)');
    }
  }
}
