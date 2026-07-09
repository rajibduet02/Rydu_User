import '../../domain/entities/rental_pricing_entity.dart';
import '../../domain/entities/rental_time_config_entity.dart';
import '../../domain/entities/rental_vehicle_entity.dart';
import '../../domain/repositories/rentals_repository.dart';
import '../datasources/rentals_local_datasource.dart';

class RentalsRepositoryImpl implements RentalsRepository {
  RentalsRepositoryImpl(this._localDatasource);

  final RentalsLocalDatasource _localDatasource;

  @override
  RentalTimeConfigEntity getTimeConfig() => _localDatasource.getTimeConfig();

  @override
  RentalPricingEntity pricingForHours(int hours) {
    return _localDatasource.pricingForHours(hours);
  }

  @override
  List<RentalVehicleEntity> vehiclesForIncludedKm(int includedKm) {
    return _localDatasource.vehiclesForIncludedKm(includedKm);
  }

  @override
  double defaultPromotionAmount() => getTimeConfig().defaultPromotionAmount;
}
