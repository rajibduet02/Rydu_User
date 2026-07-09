import '../entities/service_catalog_entry_entity.dart';
import '../repositories/services_repository.dart';

class GetServicesCatalogUsecase {
  const GetServicesCatalogUsecase(this._repository);

  final ServicesRepository _repository;

  List<ServiceCatalogEntryEntity> call() => _repository.getServiceCatalog();
}
