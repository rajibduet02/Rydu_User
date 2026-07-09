import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide async initialization (e.g. Firebase, dotenv) before [runApp].
Future<SharedPreferences> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  return SharedPreferences.getInstance();
}
