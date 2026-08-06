class GeoPointEntity {
  const GeoPointEntity({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class PlaceEntity {
  const PlaceEntity({
    required this.placeId,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.city,
    this.district,
    this.country,
    this.countryCode,
    this.postalCode,
    this.types = const [],
  });

  final String placeId;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final String? city;
  final String? district;
  final String? country;
  final String? countryCode;
  final String? postalCode;
  final List<String> types;

  bool get hasCoordinates =>
      latitude.isFinite &&
      longitude.isFinite &&
      !(latitude == 0 && longitude == 0);
}

class PlacePredictionEntity {
  const PlacePredictionEntity({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
    this.latitude,
    this.longitude,
  });

  final String placeId;
  final String primaryText;
  final String secondaryText;
  final double? latitude;
  final double? longitude;
}

class RouteBoundsEntity {
  const RouteBoundsEntity({required this.northeast, required this.southwest});

  final GeoPointEntity northeast;
  final GeoPointEntity southwest;

  bool get isValid =>
      northeast.latitude.isFinite &&
      northeast.longitude.isFinite &&
      southwest.latitude.isFinite &&
      southwest.longitude.isFinite &&
      !(northeast.latitude == southwest.latitude &&
          northeast.longitude == southwest.longitude);
}

class RoutePreviewEntity {
  const RoutePreviewEntity({
    required this.distanceMeters,
    required this.distanceKm,
    required this.durationSeconds,
    required this.durationMin,
    required this.encodedPolyline,
    required this.routeBounds,
    this.staticDurationSeconds,
    this.trafficDelaySeconds,
    this.legs = const [],
    this.provider,
    this.calculatedAt,
  });

  final int distanceMeters;
  final double distanceKm;
  final int durationSeconds;
  final int durationMin;
  final int? staticDurationSeconds;
  final int? trafficDelaySeconds;
  final String encodedPolyline;
  final RouteBoundsEntity routeBounds;
  final List<Map<String, dynamic>> legs;
  final String? provider;
  final String? calculatedAt;
}

class PromotionEntity {
  const PromotionEntity({
    this.id,
    this.title,
    this.discountType,
    this.discountValue,
  });

  final String? id;
  final String? title;
  final String? discountType;
  final double? discountValue;

  /// Short user-facing label only — never an id or raw map dump.
  String? get displayTitle {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    if (discountType != null && discountValue != null) {
      final type = discountType!.toLowerCase();
      if (type.contains('percent') || type == 'percentage') {
        return '${discountValue!.toStringAsFixed(0)}% off';
      }
      return 'Promotion applied';
    }
    return null;
  }
}

class ServiceQuoteEntity {
  const ServiceQuoteEntity({
    required this.serviceCategoryId,
    required this.serviceCode,
    required this.serviceName,
    required this.capacity,
    required this.distanceKm,
    required this.durationMin,
    required this.originalFare,
    required this.discountAmount,
    required this.finalFare,
    required this.currency,
    this.description,
    this.iconKey,
    this.driverEtaMinutes,
    this.promotion,
  });

  final String serviceCategoryId;
  final String serviceCode;
  final String serviceName;
  final String? description;
  final String? iconKey;
  final int capacity;
  final double distanceKm;
  final int durationMin;
  final int? driverEtaMinutes;
  final double originalFare;
  final double discountAmount;
  final double finalFare;
  final String currency;
  final PromotionEntity? promotion;

  bool get hasDiscount => discountAmount > 0 && originalFare > finalFare;
}

class BookingQuoteEntity {
  const BookingQuoteEntity({required this.route, required this.quotes});

  final RoutePreviewEntity route;
  final List<ServiceQuoteEntity> quotes;
}

class PaymentMethodEntity {
  const PaymentMethodEntity({
    required this.code,
    required this.label,
    this.isDefault = false,
  });

  final String code;
  final String label;
  final bool isDefault;
}

class AssignedDriverEntity {
  const AssignedDriverEntity({
    required this.id,
    required this.name,
    this.phone,
    this.plateNumber,
    this.rating,
    this.vehicleName,
    this.etaMinutes,
  });

  final String id;
  final String name;
  final String? phone;
  final String? plateNumber;
  final String? rating;
  final String? vehicleName;
  final int? etaMinutes;
}

/// Authoritative ride-video recording consent fields from booking / consent APIs.
class RecordingConsentInfo {
  const RecordingConsentInfo({
    this.consentStatus,
    this.recordingConsentedAt,
    this.consented,
    this.required,
  });

  /// Backend status string when present (`granted`, `denied`, `pending`, …).
  final String? consentStatus;

  /// ISO timestamp when consent was granted (driver contract field).
  final String? recordingConsentedAt;

  /// Explicit boolean when present on socket / consent responses.
  final bool? consented;

  /// Whether recording consent is required for this booking/session.
  final bool? required;

  bool get hasDecisionSignal =>
      (consentStatus != null && consentStatus!.trim().isNotEmpty) ||
      (recordingConsentedAt != null &&
          recordingConsentedAt!.trim().isNotEmpty) ||
      consented != null ||
      required != null;
}

class BookingEntity {
  const BookingEntity({
    required this.id,
    required this.status,
    this.bookingNumber,
    this.serviceCategoryId,
    this.serviceName,
    this.paymentMethodCode,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.currency,
    this.finalFare,
    this.driver,
    this.encodedPolyline,
    this.driverEtaMinutes,
    this.recordingConsent,
  });

  final String id;
  final String status;
  final String? bookingNumber;
  final String? serviceCategoryId;
  final String? serviceName;
  final String? paymentMethodCode;
  final String? pickupAddress;
  final String? dropoffAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String? currency;
  final double? finalFare;
  final AssignedDriverEntity? driver;
  final String? encodedPolyline;
  final int? driverEtaMinutes;
  final RecordingConsentInfo? recordingConsent;

  bool get isActive {
    final s = status.toLowerCase();
    return s != 'completed' &&
        s != 'cancelled' &&
        s != 'canceled' &&
        s != 'expired' &&
        s != 'no_drivers';
  }

  String? get formattedFare {
    if (finalFare == null) return null;
    final c = currency ?? 'BDT';
    return '$c ${finalFare!.toStringAsFixed(2)}';
  }
}

/// Result of POST …/recording-consent (fields taken only when present).
class RecordingConsentResult {
  const RecordingConsentResult({
    required this.consent,
    this.consentStatus,
    this.recordingConsentedAt,
    this.consented,
    this.required,
    this.booking,
  });

  final bool consent;
  final String? consentStatus;
  final String? recordingConsentedAt;
  final bool? consented;
  final bool? required;
  final BookingEntity? booking;

  RecordingConsentInfo get asInfo => RecordingConsentInfo(
    consentStatus: consentStatus,
    recordingConsentedAt: recordingConsentedAt,
    consented: consented ?? consent,
    required: required,
  );
}

class NearbyDriverEntity {
  const NearbyDriverEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.maskedPlate,
    this.serviceCategoryId,
  });

  final String id;
  final double latitude;
  final double longitude;
  final double? heading;
  final String? maskedPlate;
  final String? serviceCategoryId;
}

class DriverLocationEntity {
  const DriverLocationEntity({
    required this.driverId,
    required this.bookingId,
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speedKph,
    this.accuracyMeters,
    this.timestamp,
  });

  final String driverId;
  final String bookingId;
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speedKph;
  final double? accuracyMeters;
  final String? timestamp;
}

class LatLngWaypoint {
  const LatLngWaypoint({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeId,
    this.spotLabel,
  });

  final double latitude;
  final double longitude;
  final String? address;
  final String? placeId;
  final String? spotLabel;

  Map<String, dynamic> toJson({bool includeSpotLabel = false}) => {
    'latitude': latitude,
    'longitude': longitude,
    if (address != null && address!.isNotEmpty) 'address': address,
    if (placeId != null && placeId!.isNotEmpty) 'placeId': placeId,
    if (includeSpotLabel && spotLabel != null && spotLabel!.isNotEmpty)
      'spotLabel': spotLabel,
  };
}
