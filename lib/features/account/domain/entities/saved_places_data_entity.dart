import 'recent_place_entity.dart';
import 'saved_place_entity.dart';

class SavedPlacesDataEntity {
  const SavedPlacesDataEntity({
    required this.savedPlaces,
    required this.recentPlaces,
    required this.defaultPlaceId,
  });

  final List<SavedPlaceEntity> savedPlaces;
  final List<RecentPlaceEntity> recentPlaces;
  final String defaultPlaceId;
}
