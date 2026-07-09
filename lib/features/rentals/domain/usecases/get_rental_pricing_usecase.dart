import '../entities/rental_pricing_entity.dart';
import '../repositories/rentals_repository.dart';

class GetRentalPricingUsecase {
  const GetRentalPricingUsecase(this._repository);

  final RentalsRepository _repository;

  RentalPricingEntity call(int hours) => _repository.pricingForHours(hours);
}
