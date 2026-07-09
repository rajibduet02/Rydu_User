import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/offers_repository.dart';
import '../datasources/offers_local_datasource.dart';

class OffersRepositoryImpl implements OffersRepository {
  OffersRepositoryImpl(this._local);

  final OffersLocalDatasource _local;

  @override
  Future<List<OfferEntity>> getOffers() async {
    final models = await _local.fetchOffers();
    return models.map((m) => m.toEntity()).toList(growable: false);
  }
}
