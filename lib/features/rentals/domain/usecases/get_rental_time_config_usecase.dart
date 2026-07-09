import '../entities/rental_time_config_entity.dart';
import '../repositories/rentals_repository.dart';

class GetRentalTimeConfigUsecase {
  const GetRentalTimeConfigUsecase(this._repository);

  final RentalsRepository _repository;

  RentalTimeConfigEntity call() => _repository.getTimeConfig();
}
