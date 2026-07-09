import '../../domain/entities/lost_item_trip_entity.dart';

class LostItemTripModel extends LostItemTripEntity {
  const LostItemTripModel({
    required super.id,
    required super.vehicleName,
    required super.dateTime,
    required super.subtitle,
  });

  LostItemTripEntity toEntity() => this;
}
