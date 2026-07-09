import '../../domain/entities/confidence_item_entity.dart';

class ConfidenceItemModel extends ConfidenceItemEntity {
  const ConfidenceItemModel({
    required super.id,
    required super.title,
    required super.iconType,
  });

  factory ConfidenceItemModel.fromEntity(ConfidenceItemEntity entity) {
    return ConfidenceItemModel(
      id: entity.id,
      title: entity.title,
      iconType: entity.iconType,
    );
  }
}
