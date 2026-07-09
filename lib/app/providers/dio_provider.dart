import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/dio_factory.dart';
import 'storage_providers.dart';

final dioProvider = Provider<Dio>((ref) {
  return createDio(ref.watch(secureStorageServiceProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
