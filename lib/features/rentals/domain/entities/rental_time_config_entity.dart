class RentalTimeConfigEntity {
  const RentalTimeConfigEntity({
    required this.minHours,
    required this.maxHours,
    required this.kmPerHour,
    required this.discountedHourlyRate,
    required this.baseHourlyRate,
    required this.defaultPromotionAmount,
  });

  final int minHours;
  final int maxHours;
  final int kmPerHour;
  final double discountedHourlyRate;
  final double baseHourlyRate;
  final double defaultPromotionAmount;
}
