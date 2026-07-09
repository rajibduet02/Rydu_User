import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';
import 'shared_preferences_provider.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
