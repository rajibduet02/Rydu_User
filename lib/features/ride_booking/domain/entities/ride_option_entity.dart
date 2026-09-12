import 'ride_planning_entities.dart';

class RideOptionEntity {
  const RideOptionEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.time,
    required this.description,
    required this.price,
    this.capacity,
    this.originalPrice,
    this.iconEmoji = '🚗',
    this.discount = false,
    this.serviceCode,
    this.currency,
    this.finalFare,
    this.originalFare,
    this.discountAmount,
    this.driverEtaMinutes,
    this.promotion,
    this.regularFare,
    this.airportFee,
    this.airport,
  });

  final String id;
  final String name;
  final String category;
  final String time;
  final String? capacity;
  final String description;
  final String price;
  final String? originalPrice;
  final String iconEmoji;
  final bool discount;
  final String? serviceCode;
  final String? currency;
  final double? finalFare;
  final double? originalFare;
  final double? discountAmount;
  final int? driverEtaMinutes;
  final String? promotion;
  final double? regularFare;
  final double? airportFee;
  final AirportQuoteEntity? airport;

  bool get hasAirportSurcharge => (airportFee ?? 0) > 0;

  double get displayTripFare {
    if (regularFare != null) return regularFare!;
    final fee = airportFee ?? 0;
    if (finalFare != null && fee > 0) {
      final remainder = finalFare! - fee;
      return remainder < 0 ? finalFare! : remainder;
    }
    return finalFare ?? 0;
  }
}
