import '../../domain/entities/saved_places_data_entity.dart';
import '../../domain/repositories/saved_places_repository.dart';
import '../datasources/saved_places_local_datasource.dart';

class SavedPlacesRepositoryImpl implements SavedPlacesRepository {
  SavedPlacesRepositoryImpl(this._local);

  final SavedPlacesLocalDatasource _local;

  @override
  Future<SavedPlacesDataEntity> getSavedPlaces() async {
    final model = await _local.fetchSavedPlaces();
    return model.toEntity();
  }
}
