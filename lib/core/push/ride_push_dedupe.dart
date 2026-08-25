/// In-memory dedupe for FCM ride events (`bookingId` + normalized event).
class RidePushDedupe {
  RidePushDedupe();

  final Set<String> _seen = <String>{};

  bool seen(String key) => _seen.contains(key);

  /// Returns true if this key was already recorded (duplicate).
  bool record(String key) {
    if (key.isEmpty) return false;
    return !_seen.add(key);
  }

  void clear() => _seen.clear();
}
