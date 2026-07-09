import '../../domain/entities/recent_place_entity.dart';

class RecentPlaceModel extends RecentPlaceEntity {
  const RecentPlaceModel({
    required super.id,
    required super.title,
    required super.timeAgo,
  });

  RecentPlaceEntity toEntity() => this;
}
