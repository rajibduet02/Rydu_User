class MapCameraModel {
  const MapCameraModel({required this.lat, required this.lng, this.zoom = 14});

  final double lat;
  final double lng;
  final double zoom;
}
