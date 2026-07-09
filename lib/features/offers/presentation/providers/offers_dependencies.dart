import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/offers_local_datasource.dart';
import '../../data/repositories/offers_repository_impl.dart';
import '../../domain/repositories/offers_repository.dart';
import '../../domain/usecases/get_offers_usecase.dart';

final offersLocalDatasourceProvider = Provider<OffersLocalDatasource>((ref) {
  return OffersLocalDatasourceImpl();
});

final offersRepositoryProvider = Provider<OffersRepository>((ref) {
  return OffersRepositoryImpl(ref.watch(offersLocalDatasourceProvider));
});

final getOffersUsecaseProvider = Provider<GetOffersUsecase>((ref) {
  return GetOffersUsecase(ref.watch(offersRepositoryProvider));
});
