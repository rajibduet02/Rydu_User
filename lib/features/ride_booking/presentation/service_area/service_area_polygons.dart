import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/service_area/service_area_models.dart';

/// Converts a backend service-area config into Google Map polygons.
/// Returns an empty set when enforcement is off or the market is not US.
Set<Polygon> serviceAreaPolygons(ServiceAreaConfig? config) {
  if (config == null || !config.showsRestrictionPolygon) return const {};
  final polygons = <Polygon>{};
  var index = 0;
  for (final shape in config.drawablePolygons) {
    polygons.add(
      Polygon(
        polygonId: PolygonId('service-area-$index'),
        points: [
          for (final point in shape.outer.points)
            LatLng(point.latitude, point.longitude),
        ],
        holes: [
          for (final hole in shape.holes)
            [
              for (final point in hole.points)
                LatLng(point.latitude, point.longitude),
            ],
        ],
        strokeWidth: 2,
        strokeColor: const Color(0xFF1565C0),
        fillColor: const Color(0x2232A5F6),
        consumeTapEvents: false,
        zIndex: 0,
      ),
    );
    index += 1;
  }
  return polygons;
}

const serviceAreaGuidanceLabel =
    'Highlighted area is a guide. Rydu confirms whether this ride can be booked.';
