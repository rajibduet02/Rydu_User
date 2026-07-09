import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/map_remote_datasource.dart';
import '../../data/repositories/map_repository_impl.dart';
import '../../domain/repositories/map_repository.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl(MapRemoteDatasourceImpl());
});
