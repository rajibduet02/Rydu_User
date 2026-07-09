import '../../domain/entities/ride_trip_entity.dart';

class RideTripModel extends RideTripEntity {
  const RideTripModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.vehicleName,
    required super.fare,
    required super.status,
  });

  RideTripEntity toEntity() => this;
}
