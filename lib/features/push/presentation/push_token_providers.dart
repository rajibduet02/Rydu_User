import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/dio_provider.dart';
import '../data/datasources/passenger_push_remote_datasource.dart';
import '../data/repositories/passenger_push_repository_impl.dart';
import '../domain/repositories/passenger_push_repository.dart';

final passengerPushRemoteDatasourceProvider =
    Provider<PassengerPushRemoteDatasource>((ref) {
      return PassengerPushRemoteDatasourceImpl(ref.watch(apiClientProvider));
    });

final passengerPushRepositoryProvider = Provider<PassengerPushRepository>((
  ref,
) {
  return PassengerPushRepositoryImpl(
    ref.watch(passengerPushRemoteDatasourceProvider),
  );
});
