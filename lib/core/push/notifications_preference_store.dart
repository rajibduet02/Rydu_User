import 'package:shared_preferences/shared_preferences.dart';

/// User preference for ride push notifications. Independent of OS permission.
class NotificationsPreferenceStore {
  NotificationsPreferenceStore(this._prefs);

  static const enabledKey = 'passenger_notifications_enabled';
  static const promptedKey = 'passenger_notifications_os_prompted';

  final SharedPreferences _prefs;

  /// Defaults to enabled so first login can request permission once.
  bool get enabled => _prefs.getBool(enabledKey) ?? true;

  bool get osPrompted => _prefs.getBool(promptedKey) ?? false;

  Future<void> setEnabled(bool value) => _prefs.setBool(enabledKey, value);

  Future<void> markOsPrompted() => _prefs.setBool(promptedKey, true);
}
