import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/dio_provider.dart';
import '../../data/datasources/passenger_profile_remote_datasource.dart';
import '../../data/datasources/passenger_profile_remote_datasource_impl.dart';
import '../../data/repositories/passenger_profile_repository_impl.dart';
import '../../domain/repositories/passenger_profile_repository.dart';

final passengerProfileRemoteDatasourceProvider =
    Provider<PassengerProfileRemoteDatasource>((ref) {
      return PassengerProfileRemoteDatasourceImpl(ref.watch(apiClientProvider));
    });

final passengerProfileRepositoryProvider = Provider<PassengerProfileRepository>(
  (ref) {
    return PassengerProfileRepositoryImpl(
      ref.watch(passengerProfileRemoteDatasourceProvider),
    );
  },
);
