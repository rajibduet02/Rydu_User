import '../../domain/entities/rental_vehicle_entity.dart';

class RentalVehicleModel extends RentalVehicleEntity {
  const RentalVehicleModel({
    required super.id,
    required super.name,
    required super.eta,
    required super.includedKm,
    required super.price,
    required super.oldPrice,
    required super.iconType,
    super.showDiscountBolt,
  });
}
