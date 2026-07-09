import '../../domain/entities/destination_entity.dart';

class DestinationModel extends DestinationEntity {
  const DestinationModel({
    required super.id,
    required super.cityName,
    required super.startingPrice,
    required super.imagePath,
  });

  factory DestinationModel.fromEntity(DestinationEntity entity) {
    return DestinationModel(
      id: entity.id,
      cityName: entity.cityName,
      startingPrice: entity.startingPrice,
      imagePath: entity.imagePath,
    );
  }
}
