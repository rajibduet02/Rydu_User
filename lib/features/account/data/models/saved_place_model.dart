import '../../domain/entities/saved_place_entity.dart';

class SavedPlaceModel extends SavedPlaceEntity {
  const SavedPlaceModel({
    required super.id,
    required super.title,
    required super.address,
    required super.type,
    required super.iconType,
    required super.colorType,
    required super.isDefault,
  });

  SavedPlaceEntity toEntity() => this;
}
