import '../entities/offer_entity.dart';

abstract interface class OffersRepository {
  Future<List<OfferEntity>> getOffers();
}
