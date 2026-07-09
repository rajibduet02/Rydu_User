import '../entities/saved_places_data_entity.dart';

abstract interface class SavedPlacesRepository {
  Future<SavedPlacesDataEntity> getSavedPlaces();
}
