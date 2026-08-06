import '../../domain/entities/ride_planning_entities.dart';

abstract final class RidePlanningParsers {
  static double? asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round();
    }
    return null;
  }

  static String? asNonEmptyString(dynamic value) {
    if (value == null) return null;
    // Never stringify Maps/Lists into UI labels.
    if (value is Map || value is List) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return text;
  }

  static PromotionEntity? promotion(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final title = asNonEmptyString(raw);
      if (title == null) return null;
      // Reject accidental map dumps.
      if (title.startsWith('{') && title.contains(':')) return null;
      return PromotionEntity(title: title);
    }
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final title = asNonEmptyString(
      map['title'] ??
          map['name'] ??
          map['label'] ??
          map['promotionTitle'] ??
          map['text'] ??
          map['message'],
    );
    final id = asNonEmptyString(map['id'] ?? map['promotionId']);
    // Never use id as the visible title.
    if (title == null && id == null && map['discountValue'] == null) {
      return null;
    }
    return PromotionEntity(
      id: id,
      title: title,
      discountType: asNonEmptyString(map['discountType'] ?? map['type']),
      discountValue: asDouble(map['discountValue'] ?? map['value']),
    );
  }

  static GeoPointEntity? geoPoint(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final lat = asDouble(map['latitude'] ?? map['lat']);
    final lng = asDouble(map['longitude'] ?? map['lng'] ?? map['lon']);
    if (lat == null || lng == null) return null;
    return GeoPointEntity(latitude: lat, longitude: lng);
  }

  static PlacePredictionEntity? prediction(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final placeId = asNonEmptyString(map['placeId'] ?? map['id']);
    if (placeId == null) return null;
    final primary =
        asNonEmptyString(
          map['primaryText'] ??
              map['mainText'] ??
              map['label'] ??
              map['name'] ??
              map['description'],
        ) ??
        placeId;
    final secondary =
        asNonEmptyString(
          map['secondaryText'] ??
              map['secondary'] ??
              map['address'] ??
              map['subtitle'],
        ) ??
        '';
    return PlacePredictionEntity(
      placeId: placeId,
      primaryText: primary,
      secondaryText: secondary,
      latitude: asDouble(map['latitude'] ?? map['lat']),
      longitude: asDouble(map['longitude'] ?? map['lng']),
    );
  }

  static PlaceEntity? place(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final placeId = asNonEmptyString(map['placeId'] ?? map['id']) ?? '';
    final lat = asDouble(map['latitude'] ?? map['lat']);
    final lng = asDouble(map['longitude'] ?? map['lng']);
    if (lat == null || lng == null) return null;
    final label =
        asNonEmptyString(map['label'] ?? map['name'] ?? map['primaryText']) ??
        asNonEmptyString(map['address']) ??
        'Selected place';
    final address =
        asNonEmptyString(map['address'] ?? map['formattedAddress']) ?? label;
    final typesRaw = map['types'];
    final types = <String>[];
    if (typesRaw is List) {
      for (final item in typesRaw) {
        final text = item?.toString();
        if (text != null && text.isNotEmpty) types.add(text);
      }
    }
    return PlaceEntity(
      placeId: placeId,
      label: label,
      address: address,
      latitude: lat,
      longitude: lng,
      city: asNonEmptyString(map['city']),
      district: asNonEmptyString(map['district']),
      country: asNonEmptyString(map['country']),
      countryCode: asNonEmptyString(map['countryCode']),
      postalCode: asNonEmptyString(map['postalCode']),
      types: types,
    );
  }

  static RouteBoundsEntity? routeBounds(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final ne = geoPoint(map['northeast'] ?? map['northEast']);
    final sw = geoPoint(map['southwest'] ?? map['southWest']);
    if (ne == null || sw == null) return null;
    return RouteBoundsEntity(northeast: ne, southwest: sw);
  }

  static RoutePreviewEntity? routePreview(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final encoded = asNonEmptyString(map['encodedPolyline'] ?? map['polyline']);
    if (encoded == null) return null;
    final bounds =
        routeBounds(map['routeBounds'] ?? map['bounds']) ??
        const RouteBoundsEntity(
          northeast: GeoPointEntity(latitude: 0, longitude: 0),
          southwest: GeoPointEntity(latitude: 0, longitude: 0),
        );
    final distanceMeters = asInt(map['distanceMeters']) ?? 0;
    final durationSeconds = asInt(map['durationSeconds']) ?? 0;
    final distanceKm = asDouble(map['distanceKm']) ?? (distanceMeters / 1000.0);
    final durationMin =
        asInt(map['durationMin']) ??
        (durationSeconds / 60).round().clamp(0, 999999);
    final legsRaw = map['legs'];
    final legs = <Map<String, dynamic>>[];
    if (legsRaw is List) {
      for (final item in legsRaw) {
        if (item is Map) legs.add(Map<String, dynamic>.from(item));
      }
    }
    return RoutePreviewEntity(
      distanceMeters: distanceMeters,
      distanceKm: distanceKm,
      durationSeconds: durationSeconds,
      durationMin: durationMin,
      staticDurationSeconds: asInt(map['staticDurationSeconds']),
      trafficDelaySeconds: asInt(map['trafficDelaySeconds']),
      encodedPolyline: encoded,
      routeBounds: bounds,
      legs: legs,
      provider: asNonEmptyString(map['provider']),
      calculatedAt: asNonEmptyString(map['calculatedAt']),
    );
  }

  static ServiceQuoteEntity? serviceQuote(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = asNonEmptyString(
      map['serviceCategoryId'] ?? map['id'] ?? map['serviceId'],
    );
    if (id == null) return null;
    final currency = asNonEmptyString(map['currency']) ?? 'BDT';
    final finalFare = asDouble(map['finalFare'] ?? map['fare'] ?? map['price']);
    if (finalFare == null) return null;
    final original =
        asDouble(map['originalFare']) ??
        finalFare + (asDouble(map['discountAmount']) ?? 0);
    final discount = asDouble(map['discountAmount']) ?? (original - finalFare);
    return ServiceQuoteEntity(
      serviceCategoryId: id,
      serviceCode: asNonEmptyString(map['serviceCode'] ?? map['code']) ?? id,
      serviceName:
          asNonEmptyString(map['serviceName'] ?? map['name']) ?? 'Ride',
      description: asNonEmptyString(map['description']),
      iconKey: asNonEmptyString(map['iconKey'] ?? map['icon']),
      capacity: asInt(map['capacity']) ?? 4,
      distanceKm: asDouble(map['distanceKm']) ?? 0,
      durationMin: asInt(map['durationMin']) ?? 0,
      driverEtaMinutes: asInt(map['driverEtaMinutes'] ?? map['etaMinutes']),
      originalFare: original,
      discountAmount: discount < 0 ? 0 : discount,
      finalFare: finalFare,
      currency: currency,
      promotion: promotion(map['promotion'] ?? map['promotionText']),
    );
  }

  static BookingQuoteEntity? bookingQuote(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final route = routePreview(map['route'] ?? map);
    if (route == null) return null;
    final quotesRaw = map['quotes'] ?? map['services'] ?? map['options'];
    final quotes = <ServiceQuoteEntity>[];
    if (quotesRaw is List) {
      for (final item in quotesRaw) {
        final quote = serviceQuote(item);
        if (quote != null) quotes.add(quote);
      }
    }
    return BookingQuoteEntity(route: route, quotes: quotes);
  }

  static PaymentMethodEntity? paymentMethod(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final code = asNonEmptyString(map['code'] ?? map['id'] ?? map['method']);
    if (code == null) return null;
    return PaymentMethodEntity(
      code: code,
      label: asNonEmptyString(map['label'] ?? map['name']) ?? code,
      isDefault: map['isDefault'] == true || map['default'] == true,
    );
  }

  static AssignedDriverEntity? assignedDriver(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = asNonEmptyString(map['id'] ?? map['driverId']);
    final name = asNonEmptyString(
      map['name'] ?? map['fullName'] ?? map['driverName'],
    );
    if (id == null && name == null) return null;
    final etaRaw = map['etaMinutes'] ?? map['driverEtaMinutes'] ?? map['eta'];
    int? eta;
    if (etaRaw is num) {
      eta = etaRaw.round();
    } else if (etaRaw is String) {
      eta = int.tryParse(etaRaw.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    return AssignedDriverEntity(
      id: id ?? 'driver',
      name: name ?? 'Driver',
      phone: asNonEmptyString(map['phone'] ?? map['phoneNumber']),
      plateNumber: asNonEmptyString(
        map['plateNumber'] ?? map['plate'] ?? map['maskedPlate'],
      ),
      rating: asNonEmptyString(map['rating'] ?? map['driverRating']),
      vehicleName: asNonEmptyString(
        map['vehicleName'] ?? map['vehicle'] ?? map['vehicleType'],
      ),
      etaMinutes: eta,
    );
  }

  static bool? asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) {
      if (value == 1) return true;
      if (value == 0) return false;
      return null;
    }
    if (value is String) {
      final t = value.trim().toLowerCase();
      if (t == 'true' || t == '1' || t == 'yes') return true;
      if (t == 'false' || t == '0' || t == 'no') return false;
    }
    return null;
  }

  /// Parses consent fields from booking, consent POST, or socket payloads.
  /// Only reads keys known from the DriveWize driver/passenger contract.
  static RecordingConsentInfo? recordingConsent(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);

    Map<String, dynamic>? nestedRecording;
    final recording = map['recording'] ?? map['video'] ?? map['videoSession'];
    if (recording is Map) {
      nestedRecording = Map<String, dynamic>.from(recording);
    }
    final session = map['session'];
    if (session is Map) {
      nestedRecording ??= Map<String, dynamic>.from(session);
    }

    final consentStatus = asNonEmptyString(
      map['consentStatus'] ??
          map['consent_status'] ??
          map['recordingConsentStatus'] ??
          map['recording_consent_status'] ??
          nestedRecording?['consentStatus'] ??
          nestedRecording?['consent_status'] ??
          nestedRecording?['recordingConsentStatus'] ??
          nestedRecording?['recording_consent_status'],
    );
    final recordingConsentedAt = asNonEmptyString(
      map['recordingConsentedAt'] ??
          map['recording_consented_at'] ??
          nestedRecording?['recordingConsentedAt'] ??
          nestedRecording?['recording_consented_at'],
    );
    final consented = asBool(
      map['consented'] ??
          map['consent'] ??
          nestedRecording?['consented'] ??
          nestedRecording?['consent'],
    );
    final required = asBool(
      map['recordingConsentRequired'] ??
          map['recording_consent_required'] ??
          map['consentRequired'] ??
          map['consent_required'] ??
          nestedRecording?['required'] ??
          nestedRecording?['recordingRequired'] ??
          nestedRecording?['recording_required'],
    );

    final info = RecordingConsentInfo(
      consentStatus: consentStatus,
      recordingConsentedAt: recordingConsentedAt,
      consented: consented,
      required: required,
    );
    return info.hasDecisionSignal ? info : null;
  }

  static RecordingConsentResult? recordingConsentResult(
    dynamic raw, {
    required bool requestedConsent,
  }) {
    if (raw is! Map) {
      return RecordingConsentResult(consent: requestedConsent);
    }
    final map = Map<String, dynamic>.from(raw);
    final bookingRaw = map['booking'];
    final parsedBooking = booking(bookingRaw is Map ? bookingRaw : map);
    final info = recordingConsent(map) ??
        recordingConsent(bookingRaw) ??
        parsedBooking?.recordingConsent;

    return RecordingConsentResult(
      consent: info?.consented ?? requestedConsent,
      consentStatus: info?.consentStatus,
      recordingConsentedAt: info?.recordingConsentedAt,
      consented: info?.consented,
      required: info?.required,
      booking: parsedBooking,
    );
  }

  static BookingEntity? booking(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = asNonEmptyString(map['id'] ?? map['bookingId']);
    if (id == null) return null;
    final pickup = map['pickup'];
    final dropoff = map['dropoff'];
    final fare = asDouble(
      map['finalFare'] ?? map['fare'] ?? map['estimatedFare'] ?? map['price'],
    );
    final route = map['route'];
    final encoded = asNonEmptyString(
      map['encodedPolyline'] ??
          (route is Map ? route['encodedPolyline'] ?? route['polyline'] : null),
    );
    return BookingEntity(
      id: id,
      status: asNonEmptyString(map['status']) ?? 'created',
      bookingNumber: asNonEmptyString(
        map['bookingNumber'] ?? map['number'] ?? map['code'],
      ),
      serviceCategoryId: asNonEmptyString(map['serviceCategoryId']),
      serviceName: asNonEmptyString(
        map['serviceName'] ?? map['service'] ?? map['vehicleName'],
      ),
      paymentMethodCode: asNonEmptyString(map['paymentMethodCode']),
      pickupAddress: pickup is Map
          ? asNonEmptyString(pickup['address'] ?? pickup['label'])
          : asNonEmptyString(map['pickupAddress']),
      dropoffAddress: dropoff is Map
          ? asNonEmptyString(dropoff['address'] ?? dropoff['label'])
          : asNonEmptyString(map['dropoffAddress']),
      pickupLatitude: pickup is Map
          ? asDouble(pickup['latitude'] ?? pickup['lat'])
          : asDouble(map['pickupLatitude']),
      pickupLongitude: pickup is Map
          ? asDouble(pickup['longitude'] ?? pickup['lng'])
          : asDouble(map['pickupLongitude']),
      dropoffLatitude: dropoff is Map
          ? asDouble(dropoff['latitude'] ?? dropoff['lat'])
          : asDouble(map['dropoffLatitude']),
      dropoffLongitude: dropoff is Map
          ? asDouble(dropoff['longitude'] ?? dropoff['lng'])
          : asDouble(map['dropoffLongitude']),
      currency: asNonEmptyString(map['currency']),
      finalFare: fare,
      driver: assignedDriver(map['driver'] ?? map['assignedDriver']),
      encodedPolyline: encoded,
      driverEtaMinutes: () {
        final v = map['driverEtaMinutes'] ?? map['etaMinutes'];
        if (v is num) return v.round();
        if (v is String) return int.tryParse(v);
        return null;
      }(),
      recordingConsent: recordingConsent(map),
    );
  }

  static NearbyDriverEntity? nearbyDriver(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = asNonEmptyString(map['id'] ?? map['driverId']);
    final lat = asDouble(map['latitude'] ?? map['lat']);
    final lng = asDouble(map['longitude'] ?? map['lng']);
    if (id == null || lat == null || lng == null) return null;
    return NearbyDriverEntity(
      id: id,
      latitude: lat,
      longitude: lng,
      heading: asDouble(map['heading']),
      maskedPlate: asNonEmptyString(
        map['maskedPlate'] ?? map['plateNumber'] ?? map['plate'],
      ),
      serviceCategoryId: asNonEmptyString(map['serviceCategoryId']),
    );
  }

  static DriverLocationEntity? driverLocation(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final driverId = asNonEmptyString(map['driverId']);
    final bookingId = asNonEmptyString(map['bookingId']);
    final lat = asDouble(map['latitude'] ?? map['lat']);
    final lng = asDouble(map['longitude'] ?? map['lng']);
    if (driverId == null || bookingId == null || lat == null || lng == null) {
      return null;
    }
    return DriverLocationEntity(
      driverId: driverId,
      bookingId: bookingId,
      latitude: lat,
      longitude: lng,
      heading: asDouble(map['heading']),
      speedKph: asDouble(map['speedKph']),
      accuracyMeters: asDouble(map['accuracyMeters']),
      timestamp: asNonEmptyString(map['timestamp']),
    );
  }
}
