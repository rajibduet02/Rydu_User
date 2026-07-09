import '../../domain/entities/ride_option_entity.dart';

export '../../domain/entities/ride_option_entity.dart';

typedef RideVehicleOption = RideOptionEntity;

extension RideVehicleOptionPresentation on RideOptionEntity {
  Map<String, dynamic> toExtra() => {
    'id': id,
    'name': name,
    'category': category,
    'time': time,
    'capacity': capacity,
    'description': description,
    'price': price,
    'originalPrice': originalPrice,
    'iconEmoji': iconEmoji,
    'discount': discount,
  };
}

RideOptionEntity? rideVehicleOptionFromExtra(Object? raw) {
  if (raw is RideOptionEntity) return raw;
  if (raw is! Map) return null;
  final m = Map<String, dynamic>.from(raw);
  final id = m['id'] as String?;
  final name = m['name'] as String?;
  if (id == null || name == null) return null;
  return RideOptionEntity(
    id: id,
    name: name,
    category: m['category'] as String? ?? 'recommended',
    time: m['time'] as String? ?? '',
    description: m['description'] as String? ?? '',
    price: m['price'] as String? ?? '',
    capacity: m['capacity'] as String?,
    originalPrice: m['originalPrice'] as String?,
    iconEmoji: m['iconEmoji'] as String? ?? '🚗',
    discount: m['discount'] as bool? ?? false,
  );
}
