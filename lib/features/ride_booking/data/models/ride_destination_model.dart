import '../../domain/entities/ride_destination_entity.dart';

class RideDestinationModel extends RideDestinationEntity {
  const RideDestinationModel({
    required super.id,
    required super.name,
    required super.address,
    required super.distance,
    super.latitude,
    super.longitude,
    super.placeId,
  });
}
