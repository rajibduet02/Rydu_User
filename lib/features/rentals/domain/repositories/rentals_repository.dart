import '../entities/rental_pricing_entity.dart';
import '../entities/rental_time_config_entity.dart';
import '../entities/rental_vehicle_entity.dart';

abstract interface class RentalsRepository {
  RentalTimeConfigEntity getTimeConfig();
  RentalPricingEntity pricingForHours(int hours);
  List<RentalVehicleEntity> vehiclesForIncludedKm(int includedKm);
  double defaultPromotionAmount();
}
