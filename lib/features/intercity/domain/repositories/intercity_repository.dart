import '../entities/intercity_content_entity.dart';

abstract interface class IntercityRepository {
  Future<IntercityContentEntity> loadIntercityContent();
}
