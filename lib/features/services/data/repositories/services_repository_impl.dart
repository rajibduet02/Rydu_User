import '../../domain/entities/service_catalog_entry_entity.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_local_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  ServicesRepositoryImpl(this._localDatasource);

  final ServicesLocalDatasource _localDatasource;

  @override
  List<ServiceCatalogEntryEntity> getServiceCatalog() {
    return _localDatasource.getCatalog();
  }

  @override
  bool isKnownService(String serviceId) {
    return _localDatasource.getCatalog().any((e) => e.id == serviceId);
  }
}
