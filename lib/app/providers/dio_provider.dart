import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/device/passenger_device_identity.dart';
import '../../core/network/api_client.dart';
import '../../core/network/dio_factory.dart';
import 'shared_preferences_provider.dart';
import 'storage_providers.dart';

final passengerDeviceIdentityProvider = Provider<PassengerDeviceIdentity>((
  ref,
) {
  return PassengerDeviceIdentity(ref.watch(sharedPreferencesProvider));
});

final dioProvider = Provider<Dio>((ref) {
  return createDio(
    ref.watch(secureStorageServiceProvider),
    deviceIdentity: ref.watch(passengerDeviceIdentityProvider),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
