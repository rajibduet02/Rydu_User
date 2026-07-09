import '../../domain/entities/offer_entity.dart';
import '../models/offer_model.dart';

abstract interface class OffersLocalDatasource {
  Future<List<OfferModel>> fetchOffers();
}

class OffersLocalDatasourceImpl implements OffersLocalDatasource {
  static const _dummyOffers = <OfferModel>[
    OfferModel(
      id: 'premier',
      title: '30% off Premier',
      subtitle: '2 left · Up to BDT 200 off · Bangladesh',
      expiryText: 'Use by May 25, 2026',
      badgeText: 'Uber One exclusive offer',
      discountType: 'premier',
      actionType: OfferActionType.premium,
      iconAccent: OfferIconAccent.gold,
    ),
    OfferModel(
      id: 'intercity',
      title: '10% off Intercity and other select product types',
      subtitle: '1 left · Up to BDT 50 off · Bangladesh',
      expiryText: 'Use by May 25, 2026',
      badgeText: 'Uber One exclusive offer',
      discountType: 'intercity',
      actionType: OfferActionType.intercity,
      iconAccent: OfferIconAccent.gold,
    ),
    OfferModel(
      id: 'select-product',
      title: '15% off select product types',
      subtitle: '1 left · Up to BDT 500 off · Bangladesh',
      expiryText: 'Use by Oct 1, 2029',
      discountType: 'select-product',
      actionType: OfferActionType.ride,
      iconAccent: OfferIconAccent.red,
    ),
  ];

  @override
  Future<List<OfferModel>> fetchOffers() async {
    // TODO: Replace with API when offers endpoint is ready.
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _dummyOffers;
  }
}
