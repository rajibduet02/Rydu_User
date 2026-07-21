class RideDestinationEntity {
  const RideDestinationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  final String id;
  final String name;
  final String address;
  final String distance;
  final double? latitude;
  final double? longitude;
  final String? placeId;

  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite;

  RideDestinationEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? distance,
    double? latitude,
    double? longitude,
    String? placeId,
  }) {
    return RideDestinationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
    );
  }
}
