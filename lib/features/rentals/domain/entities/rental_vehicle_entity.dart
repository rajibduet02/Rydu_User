enum RentalVehicleIconType { car, suv }

class RentalVehicleEntity {
  const RentalVehicleEntity({
    required this.id,
    required this.name,
    required this.eta,
    required this.includedKm,
    required this.price,
    required this.oldPrice,
    required this.iconType,
    this.showDiscountBolt = true,
  });

  final String id;
  final String name;
  final String eta;
  final int includedKm;
  final double price;
  final double oldPrice;
  final RentalVehicleIconType iconType;
  final bool showDiscountBolt;
}
