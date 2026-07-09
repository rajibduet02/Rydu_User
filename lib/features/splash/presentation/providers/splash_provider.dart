import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/splash_local_datasource.dart';
import '../../data/repositories/splash_repository_impl.dart';
import '../../domain/repositories/splash_repository.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepositoryImpl(SplashLocalDatasourceImpl());
});
