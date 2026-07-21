import '../../domain/entities/ride_option_entity.dart';
import '../../domain/entities/ride_planning_entities.dart';

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
    'serviceCode': serviceCode,
    'currency': currency,
    'finalFare': finalFare,
    'originalFare': originalFare,
    'discountAmount': discountAmount,
    'driverEtaMinutes': driverEtaMinutes,
    'promotion': promotion,
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
    serviceCode: m['serviceCode'] as String?,
    currency: m['currency'] as String?,
    finalFare: (m['finalFare'] as num?)?.toDouble(),
    originalFare: (m['originalFare'] as num?)?.toDouble(),
    discountAmount: (m['discountAmount'] as num?)?.toDouble(),
    driverEtaMinutes: m['driverEtaMinutes'] as int?,
    promotion: m['promotion'] as String?,
  );
}

RideOptionEntity rideOptionFromQuote(
  ServiceQuoteEntity quote, {
  String category = 'recommended',
}) {
  final currency = quote.currency;
  String money(double value) => '$currency ${value.toStringAsFixed(2)}';
  final eta = quote.driverEtaMinutes;
  final time = eta != null ? '$eta min' : '${quote.durationMin} min';
  return RideOptionEntity(
    id: quote.serviceCategoryId,
    name: quote.serviceName,
    category: category,
    time: time,
    capacity: quote.capacity.toString(),
    description: quote.description ?? quote.serviceCode,
    price: money(quote.finalFare),
    originalPrice: quote.hasDiscount ? money(quote.originalFare) : null,
    iconEmoji: _iconFor(quote.iconKey ?? quote.serviceCode),
    discount: quote.hasDiscount,
    serviceCode: quote.serviceCode,
    currency: quote.currency,
    finalFare: quote.finalFare,
    originalFare: quote.originalFare,
    discountAmount: quote.discountAmount,
    driverEtaMinutes: quote.driverEtaMinutes,
    promotion: quote.promotion?.displayTitle,
  );
}

String _iconFor(String key) {
  final lower = key.toLowerCase();
  if (lower.contains('bike') || lower.contains('moto')) return '🏍️';
  if (lower.contains('cng')) return '⚡';
  if (lower.contains('xl') || lower.contains('suv')) return '🚙';
  return '🚗';
}
