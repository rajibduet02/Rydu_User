import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/push/passenger_firebase.dart';

/// App-wide async initialization (Firebase, SharedPreferences) before [runApp].
Future<SharedPreferences> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializePassengerFirebase();
  return SharedPreferences.getInstance();
}
