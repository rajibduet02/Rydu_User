import '../entities/saved_places_data_entity.dart';
import '../repositories/saved_places_repository.dart';

class GetSavedPlacesUsecase {
  GetSavedPlacesUsecase(this._repository);

  final SavedPlacesRepository _repository;

  Future<SavedPlacesDataEntity> call() => _repository.getSavedPlaces();
}
