import '../../domain/entities/saved_places_data_entity.dart';
import 'recent_place_model.dart';
import 'saved_place_model.dart';

class SavedPlacesDataModel extends SavedPlacesDataEntity {
  const SavedPlacesDataModel({
    required super.savedPlaces,
    required super.recentPlaces,
    required super.defaultPlaceId,
  });

  factory SavedPlacesDataModel.fromSeed() {
    return const SavedPlacesDataModel(
      defaultPlaceId: '1',
      savedPlaces: [
        SavedPlaceModel(
          id: '1',
          title: 'Home',
          address: 'House 45, Road 12, Gulshan 1, Dhaka',
          type: 'home',
          iconType: 'home',
          colorType: 'blue',
          isDefault: true,
        ),
        SavedPlaceModel(
          id: '2',
          title: 'Work',
          address: 'Bashundhara City, Level 5, Panthapath, Dhaka',
          type: 'work',
          iconType: 'work',
          colorType: 'orange',
          isDefault: false,
        ),
        SavedPlaceModel(
          id: '3',
          title: 'Favorite Cafe',
          address: 'Crimson Cup, Banani 11, Dhaka',
          type: 'custom',
          iconType: 'star',
          colorType: 'pink',
          isDefault: false,
        ),
        SavedPlaceModel(
          id: '4',
          title: 'Gym',
          address: 'Fitness Zone, Dhanmondi 27, Dhaka',
          type: 'custom',
          iconType: 'pin',
          colorType: 'green',
          isDefault: false,
        ),
      ],
      recentPlaces: [
        RecentPlaceModel(
          id: 'r1',
          title: 'Jamuna Future Park, Dhaka',
          timeAgo: '2 days ago',
        ),
        RecentPlaceModel(
          id: 'r2',
          title: 'Uttara Sector 7, Dhaka',
          timeAgo: '1 week ago',
        ),
        RecentPlaceModel(
          id: 'r3',
          title: 'Mohakhali DOHS, Dhaka',
          timeAgo: '2 weeks ago',
        ),
      ],
    );
  }

  SavedPlacesDataEntity toEntity() => this;
}
