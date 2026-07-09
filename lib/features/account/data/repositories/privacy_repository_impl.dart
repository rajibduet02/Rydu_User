import '../../domain/repositories/privacy_repository.dart';
import '../datasources/privacy_local_datasource.dart';

class PrivacyRepositoryImpl implements PrivacyRepository {
  PrivacyRepositoryImpl(this._local);

  final PrivacyLocalDatasource _local;

  @override
  Future<void> requestDataDownload() => _local.requestDataDownload();
}
