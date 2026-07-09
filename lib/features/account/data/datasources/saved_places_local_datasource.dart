import '../models/saved_places_data_model.dart';

abstract interface class SavedPlacesLocalDatasource {
  Future<SavedPlacesDataModel> fetchSavedPlaces();
}

class SavedPlacesLocalDatasourceImpl implements SavedPlacesLocalDatasource {
  @override
  Future<SavedPlacesDataModel> fetchSavedPlaces() async {
    // TODO: Load saved + recent places from backend / maps service.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return SavedPlacesDataModel.fromSeed();
  }
}
