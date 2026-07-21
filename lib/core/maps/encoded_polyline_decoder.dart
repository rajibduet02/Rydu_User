import 'dart:math' as math;

/// Decodes Google encoded polylines into latitude/longitude pairs.
///
/// Does not call any Google HTTP API — decoding only.
abstract final class EncodedPolylineDecoder {
  static List<({double lat, double lng})> decode(String encoded) {
    if (encoded.isEmpty) return const [];

    final points = <({double lat, double lng})>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var result = 0;
      var shift = 0;
      int b;
      do {
        if (index >= encoded.length) return points;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      result = 0;
      shift = 0;
      do {
        if (index >= encoded.length) return points;
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add((lat: lat / 1e5, lng: lng / 1e5));
    }

    return points;
  }

  /// Builds southwest/northeast bounds from decoded points.
  static ({
    ({double lat, double lng}) southwest,
    ({double lat, double lng}) northeast,
  })?
  boundsFromPoints(List<({double lat, double lng})> points) {
    if (points.isEmpty) return null;
    var minLat = points.first.lat;
    var maxLat = points.first.lat;
    var minLng = points.first.lng;
    var maxLng = points.first.lng;
    for (final p in points.skip(1)) {
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
      minLng = math.min(minLng, p.lng);
      maxLng = math.max(maxLng, p.lng);
    }
    if (minLat == maxLat && minLng == maxLng) {
      const pad = 0.002;
      return (
        southwest: (lat: minLat - pad, lng: minLng - pad),
        northeast: (lat: maxLat + pad, lng: maxLng + pad),
      );
    }
    return (
      southwest: (lat: minLat, lng: minLng),
      northeast: (lat: maxLat, lng: maxLng),
    );
  }
}
