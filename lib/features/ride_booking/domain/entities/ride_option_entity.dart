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
}
