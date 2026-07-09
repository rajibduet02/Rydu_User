import '../repositories/rentals_repository.dart';

class GetDefaultPromotionAmountUsecase {
  const GetDefaultPromotionAmountUsecase(this._repository);

  final RentalsRepository _repository;

  double call() => _repository.defaultPromotionAmount();
}
