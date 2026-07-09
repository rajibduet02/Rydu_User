import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ride_history_remote_datasource.dart';
import '../../data/repositories/ride_history_repository_impl.dart';
import '../../domain/repositories/ride_history_repository.dart';

final rideHistoryRepositoryProvider = Provider<RideHistoryRepository>((ref) {
  return RideHistoryRepositoryImpl(RideHistoryRemoteDatasourceImpl());
});
