import '../entities/offer_entity.dart';
import '../repositories/offers_repository.dart';

class GetOffersUsecase {
  GetOffersUsecase(this._repository);

  final OffersRepository _repository;

  Future<List<OfferEntity>> call() => _repository.getOffers();
}
