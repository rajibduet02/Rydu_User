import '../entities/ride_planning_entities.dart';
import 'service_area_models.dart';

/// GeoJSON rings are `[longitude, latitude]`. These helpers never swap that
/// order the other way.
abstract final class ServiceAreaGeometry {
  static GeoPointEntity? pointFromGeoJson(dynamic pair) {
    if (pair is! List || pair.length < 2) return null;
    final longitude = _asDouble(pair[0]);
    final latitude = _asDouble(pair[1]);
    if (longitude == null || latitude == null) return null;
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return null;
    }
    return GeoPointEntity(latitude: latitude, longitude: longitude);
  }

  static ServiceAreaRing? ringFromGeoJson(dynamic raw) {
    if (raw is! List) return null;
    final points = <GeoPointEntity>[];
    for (final pair in raw) {
      final point = pointFromGeoJson(pair);
      if (point != null) points.add(point);
    }
    if (points.length >= 2) {
      final first = points.first;
      final last = points.last;
      if (first.latitude == last.latitude && first.longitude == last.longitude) {
        points.removeLast();
      }
    }
    if (points.length < 3) return null;
    return ServiceAreaRing(List.unmodifiable(points));
  }

  static List<ServiceAreaPolygonShape> polygonsFromGeometry(dynamic geometry) {
    if (geometry is! Map) return const [];
    final map = Map<String, dynamic>.from(geometry);
    final type = map['type']?.toString();
    final coordinates = map['coordinates'];
    if (type == 'Polygon') {
      final polygon = _polygonFromCoordinateSet(coordinates);
      return polygon == null ? const [] : [polygon];
    }
    if (type == 'MultiPolygon') {
      if (coordinates is! List) return const [];
      final shapes = <ServiceAreaPolygonShape>[];
      for (final polygonCoords in coordinates) {
        final polygon = _polygonFromCoordinateSet(polygonCoords);
        if (polygon != null) shapes.add(polygon);
      }
      return shapes;
    }
    return const [];
  }

  static bool contains(ServiceAreaConfig config, double latitude, double longitude) {
    for (final polygon in config.drawablePolygons) {
      if (_polygonContains(polygon, latitude, longitude)) return true;
    }
    return false;
  }

  static ServiceAreaPolygonShape? _polygonFromCoordinateSet(dynamic coordinates) {
    if (coordinates is! List || coordinates.isEmpty) return null;
    final outer = ringFromGeoJson(coordinates.first);
    if (outer == null) return null;
    final holes = <ServiceAreaRing>[];
    for (var i = 1; i < coordinates.length; i++) {
      final hole = ringFromGeoJson(coordinates[i]);
      if (hole != null) holes.add(hole);
    }
    return ServiceAreaPolygonShape(outer: outer, holes: holes);
  }

  static bool _polygonContains(
    ServiceAreaPolygonShape polygon,
    double latitude,
    double longitude,
  ) {
    if (!_ringContains(polygon.outer.points, latitude, longitude)) {
      return false;
    }
    for (final hole in polygon.holes) {
      if (_ringContains(hole.points, latitude, longitude)) return false;
    }
    return true;
  }

  /// Even-odd ray cast. Points on an edge count as inside the ring.
  static bool _ringContains(
    List<GeoPointEntity> ring,
    double latitude,
    double longitude,
  ) {
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final yi = ring[i].latitude;
      final xi = ring[i].longitude;
      final yj = ring[j].latitude;
      final xj = ring[j].longitude;
      if (_onSegment(xi, yi, xj, yj, longitude, latitude)) return true;
      final crosses = (yi > latitude) != (yj > latitude);
      if (!crosses) continue;
      final xAtLat = (xj - xi) * (latitude - yi) / (yj - yi) + xi;
      if (longitude < xAtLat) inside = !inside;
    }
    return inside;
  }

  static bool _onSegment(
    double x1,
    double y1,
    double x2,
    double y2,
    double x,
    double y,
  ) {
    const epsilon = 1e-9;
    final cross = (y - y1) * (x2 - x1) - (x - x1) * (y2 - y1);
    if (cross.abs() > epsilon) return false;
    final dot = (x - x1) * (x2 - x1) + (y - y1) * (y2 - y1);
    if (dot < -epsilon) return false;
    final lenSq = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
    return dot <= lenSq + epsilon;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
