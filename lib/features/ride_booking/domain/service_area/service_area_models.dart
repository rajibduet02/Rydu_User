import '../entities/ride_planning_entities.dart';

/// One linear ring. Points are latitude/longitude (not GeoJSON order).
class ServiceAreaRing {
  const ServiceAreaRing(this.points);

  final List<GeoPointEntity> points;

  bool get isDrawable => points.length >= 3;
}

class ServiceAreaPolygonShape {
  const ServiceAreaPolygonShape({
    required this.outer,
    this.holes = const [],
  });

  final ServiceAreaRing outer;
  final List<ServiceAreaRing> holes;

  bool get isDrawable => outer.isDrawable;
}

class ServiceAreaRegion {
  const ServiceAreaRegion({
    required this.code,
    required this.name,
    required this.version,
    required this.policy,
    required this.polygons,
  });

  final String code;
  final String name;
  final int version;
  final String policy;
  final List<ServiceAreaPolygonShape> polygons;
}

class ServiceAreaConfig {
  const ServiceAreaConfig({
    required this.marketCode,
    required this.enforcementEnabled,
    required this.areas,
  });

  final String marketCode;
  final bool enforcementEnabled;
  final List<ServiceAreaRegion> areas;

  String get normalizedMarket => marketCode.trim().toUpperCase();

  int get maxVersion {
    var version = 0;
    for (final area in areas) {
      if (area.version > version) version = area.version;
    }
    return version;
  }

  bool get isUsMarket => normalizedMarket == 'US';

  bool get isBdMarket => normalizedMarket == 'BD';

  /// Drawn only for an enforced US boundary returned by the backend.
  bool get showsRestrictionPolygon =>
      isUsMarket && enforcementEnabled && drawablePolygons.isNotEmpty;

  List<ServiceAreaPolygonShape> get drawablePolygons {
    final shapes = <ServiceAreaPolygonShape>[];
    for (final area in areas) {
      for (final polygon in area.polygons) {
        if (polygon.isDrawable) shapes.add(polygon);
      }
    }
    return shapes;
  }

  /// Local checks apply only while US enforcement is on and geometry exists.
  /// Bangladesh and disabled enforcement never block.
  bool get canApplyLocalRestriction =>
      isUsMarket && enforcementEnabled && drawablePolygons.isNotEmpty;
}

/// Pickup coordinates used to ask which market applies.
/// Device GPS is intentionally not part of this query.
class ServiceAreaQuery {
  const ServiceAreaQuery({
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  final double latitude;
  final double longitude;
  final String? placeId;

  bool get usesDeviceLocation => false;

  factory ServiceAreaQuery.forPickup(PlaceEntity pickup) {
    final id = pickup.placeId.trim();
    return ServiceAreaQuery(
      latitude: pickup.latitude,
      longitude: pickup.longitude,
      placeId: id.isEmpty ? null : id,
    );
  }

  String get cacheKey {
    final id = placeId?.trim() ?? '';
    return '${latitude.toStringAsFixed(5)}|${longitude.toStringAsFixed(5)}|$id';
  }
}

class ServiceAreaDecision {
  const ServiceAreaDecision({
    required this.config,
    required this.allowsQuoteOrBooking,
    required this.serviceUnavailable,
    this.message,
    this.failedPoints = const [],
  });

  final ServiceAreaConfig? config;
  final bool allowsQuoteOrBooking;
  final bool serviceUnavailable;
  final String? message;
  final List<String> failedPoints;

  bool get showsRestrictionPolygon =>
      config?.showsRestrictionPolygon ?? false;

  const ServiceAreaDecision.idle()
    : config = null,
      allowsQuoteOrBooking = true,
      serviceUnavailable = false,
      message = null,
      failedPoints = const [];

  const ServiceAreaDecision.cleared()
    : config = null,
      allowsQuoteOrBooking = true,
      serviceUnavailable = false,
      message = null,
      failedPoints = const [];

  const ServiceAreaDecision.unavailable()
    : config = null,
      allowsQuoteOrBooking = false,
      serviceUnavailable = true,
      message = serviceAreaUnavailableMessage,
      failedPoints = const [];
}

const serviceAreaOutOfBoundsMessage =
    'This ride is outside the current service area.';

const serviceAreaUnavailableMessage =
    'The service area is temporarily unavailable. Please try again later.';
