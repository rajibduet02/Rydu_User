class RentalPricingEntity {
  const RentalPricingEntity({
    required this.selectedHours,
    required this.includedKm,
    required this.currentPrice,
    required this.originalPrice,
  });

  final int selectedHours;
  final int includedKm;
  final double currentPrice;
  final double originalPrice;
}
