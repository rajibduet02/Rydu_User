import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Single persistent Passenger device UUID.
///
/// Generated once, reused for login `deviceId`, `X-Device-ID`, and push-token
/// registration. Not cleared on logout. Reinstall may mint a new id.
class PassengerDeviceIdentity {
  PassengerDeviceIdentity(
    this._prefs, {
    String Function()? generateId,
  }) : _generateId = generateId ?? const Uuid().v4;

  static const storageKey = 'passenger_device_id';

  final SharedPreferences _prefs;
  final String Function() _generateId;
  String? _cached;

  Future<String> getOrCreate() async {
    final cached = _cached;
    if (cached != null && cached.isNotEmpty) return cached;

    final existing = _prefs.getString(storageKey);
    if (existing != null && existing.isNotEmpty) {
      _cached = existing;
      return existing;
    }

    final id = _generateId().trim();
    if (id.isEmpty) {
      throw StateError('Device id generator returned an empty value.');
    }
    await _prefs.setString(storageKey, id);
    _cached = id;
    return id;
  }
}
