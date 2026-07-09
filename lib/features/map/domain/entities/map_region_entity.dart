class MapRegionEntity {
  const MapRegionEntity({
    required this.northEastLat,
    required this.northEastLng,
    required this.southWestLat,
    required this.southWestLng,
  });

  final double northEastLat;
  final double northEastLng;
  final double southWestLat;
  final double southWestLng;
}
