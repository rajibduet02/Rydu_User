import '../entities/rental_vehicle_entity.dart';
import '../repositories/rentals_repository.dart';

class GetRentalVehiclesUsecase {
  const GetRentalVehiclesUsecase(this._repository);

  final RentalsRepository _repository;

  List<RentalVehicleEntity> call(int includedKm) {
    return _repository.vehiclesForIncludedKm(includedKm);
  }
}
