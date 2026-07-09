import 'confidence_item_entity.dart';
import 'destination_entity.dart';

class IntercityContentEntity {
  const IntercityContentEntity({
    required this.popularDestinations,
    required this.confidenceItems,
  });

  final List<DestinationEntity> popularDestinations;
  final List<ConfidenceItemEntity> confidenceItems;
}
