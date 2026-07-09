import '../entities/service_catalog_entry_entity.dart';

abstract interface class ServicesRepository {
  List<ServiceCatalogEntryEntity> getServiceCatalog();
  bool isKnownService(String serviceId);
}
