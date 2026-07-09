import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/intercity_local_datasource.dart';
import '../../data/repositories/intercity_repository_impl.dart';
import '../../domain/repositories/intercity_repository.dart';
import '../../domain/usecases/load_intercity_content_usecase.dart';

final intercityLocalDatasourceProvider = Provider<IntercityLocalDatasource>((
  ref,
) {
  return IntercityLocalDatasourceImpl();
});

final intercityRepositoryProvider = Provider<IntercityRepository>((ref) {
  return IntercityRepositoryImpl(ref.watch(intercityLocalDatasourceProvider));
});

final loadIntercityContentUsecaseProvider =
    Provider<LoadIntercityContentUsecase>((ref) {
      return LoadIntercityContentUsecase(
        ref.watch(intercityRepositoryProvider),
      );
    });
