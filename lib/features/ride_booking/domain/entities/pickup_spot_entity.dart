class PickupSpotEntity {
  const PickupSpotEntity({
    required this.index,
    required this.label,
    this.id,
    this.latitude,
    this.longitude,
    this.address,
    this.source,
  });

  final int index;
  final String label;
  final String? id;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? source;
}
