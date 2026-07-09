import '../../domain/entities/rental_pricing_entity.dart';
import '../../domain/entities/rental_time_config_entity.dart';
import '../../domain/entities/rental_vehicle_entity.dart';
import '../models/rental_vehicle_model.dart';

abstract interface class RentalsLocalDatasource {
  RentalTimeConfigEntity getTimeConfig();
  RentalPricingEntity pricingForHours(int hours);
  List<RentalVehicleModel> vehiclesForIncludedKm(int includedKm);
}

class RentalsLocalDatasourceImpl implements RentalsLocalDatasource {
  static const _config = RentalTimeConfigEntity(
    minHours: 1,
    maxHours: 12,
    kmPerHour: 15,
    discountedHourlyRate: 389.25,
    baseHourlyRate: 519.0,
    defaultPromotionAmount: 171.75,
  );

  @override
  RentalTimeConfigEntity getTimeConfig() => _config;

  @override
  RentalPricingEntity pricingForHours(int hours) {
    final h = hours.clamp(_config.minHours, _config.maxHours);
    return RentalPricingEntity(
      selectedHours: h,
      includedKm: h * _config.kmPerHour,
      currentPrice: _config.discountedHourlyRate * h,
      originalPrice: _config.baseHourlyRate * h,
    );
  }

  @override
  List<RentalVehicleModel> vehiclesForIncludedKm(int includedKm) {
    return [
      RentalVehicleModel(
        id: 'uberx-rentals',
        name: 'UberX Rentals',
        eta: '6 min away',
        includedKm: includedKm,
        price: 389.25,
        oldPrice: 519.0,
        iconType: RentalVehicleIconType.car,
      ),
      RentalVehicleModel(
        id: 'xl-rentals',
        name: 'XL Rentals',
        eta: '14 min away',
        includedKm: includedKm,
        price: 618.0,
        oldPrice: 824.0,
        iconType: RentalVehicleIconType.suv,
      ),
      RentalVehicleModel(
        id: 'premier-rentals',
        name: 'Premier Rentals',
        eta: '6 min away',
        includedKm: includedKm,
        price: 449.25,
        oldPrice: 599.0,
        iconType: RentalVehicleIconType.car,
      ),
    ];
  }
}
