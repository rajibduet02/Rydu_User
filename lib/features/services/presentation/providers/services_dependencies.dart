import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/services_local_datasource.dart';
import '../../data/repositories/services_repository_impl.dart';
import '../../domain/repositories/services_repository.dart';
import '../../domain/usecases/get_services_catalog_usecase.dart';

final servicesLocalDatasourceProvider = Provider<ServicesLocalDatasource>((
  ref,
) {
  return ServicesLocalDatasourceImpl();
});

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepositoryImpl(ref.watch(servicesLocalDatasourceProvider));
});

final getServicesCatalogUsecaseProvider = Provider<GetServicesCatalogUsecase>((
  ref,
) {
  return GetServicesCatalogUsecase(ref.watch(servicesRepositoryProvider));
});
