import '../../domain/entities/ride_option_entity.dart';

class RideOptionModel extends RideOptionEntity {
  const RideOptionModel({
    required super.id,
    required super.name,
    required super.category,
    required super.time,
    required super.description,
    required super.price,
    super.capacity,
    super.originalPrice,
    super.iconEmoji,
    super.discount,
    super.serviceCode,
    super.currency,
    super.finalFare,
    super.originalFare,
    super.discountAmount,
    super.driverEtaMinutes,
    super.promotion,
  });
}
