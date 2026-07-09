import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers/shared_preferences_provider.dart';
import 'bootstrap.dart';

Future<void> main() async {
  final prefs = await bootstrap();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const RyduUserApp(),
    ),
  );
}
