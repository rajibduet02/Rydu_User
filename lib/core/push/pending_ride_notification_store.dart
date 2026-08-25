import 'ride_push_event.dart';

/// Holds a notification tap until splash/session restore has finished.
class PendingRideNotificationStore {
  RidePushEvent? _pending;

  RidePushEvent? get pending => _pending;

  void set(RidePushEvent? event) {
    _pending = event;
  }

  RidePushEvent? take() {
    final event = _pending;
    _pending = null;
    return event;
  }

  void clear() {
    _pending = null;
  }
}
