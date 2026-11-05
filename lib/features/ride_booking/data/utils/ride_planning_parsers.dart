import '../../../../core/network/api_response_parser.dart';
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

  /// Uppercase ISO 3166-1 alpha-2, or null if missing/invalid.
  ///
  /// Does not map country names (e.g. "Bangladesh") or dial codes.
  static String? normalizedCountryCode(String? raw) {
    final text = asNonEmptyString(raw);
    if (text == null) return null;
    final code = text.toUpperCase();
    if (code.length != 2) return null;
    if (!_isAsciiLetter(code.codeUnitAt(0)) ||
        !_isAsciiLetter(code.codeUnitAt(1))) {
      return null;
    }
    return code;
  }

  static bool _isAsciiLetter(int unit) => unit >= 65 && unit <= 90;

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
      countryCode: asNonEmptyString(map['countryCode'] ?? map['country_code']),
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

  static ServiceQuoteEntity? serviceQuote(
    dynamic raw, {
    AirportQuoteEntity? defaultAirport,
    double? defaultAirportFee,
    double? defaultRegularFare,
  }) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = asNonEmptyString(
      map['serviceCategoryId'] ?? map['id'] ?? map['serviceId'],
    );
    if (id == null) return null;
    final fareNested = asMap(map['fare']);
    final currency =
        asNonEmptyString(map['currency'] ?? fareNested?['currency']) ?? 'BDT';
    final finalFare =
        asDouble(map['finalFare']) ??
        asDouble(map['price']) ??
        asDouble(fareNested?['amount'] ?? fareNested?['finalFare']) ??
        (map['fare'] is Map ? null : asDouble(map['fare']));
    if (finalFare == null) return null;
    final original =
        asDouble(map['originalFare']) ??
        finalFare + (asDouble(map['discountAmount']) ?? 0);
    final discount = asDouble(map['discountAmount']) ?? (original - finalFare);
    final airportFee =
        asDouble(
          map['airportFee'] ??
              map['airport_fee'] ??
              fareNested?['airportFee'] ??
              fareNested?['airport_fee'],
        ) ??
        defaultAirportFee ??
        0;
    final regularFare = asDouble(
      map['regularFare'] ??
          map['regular_fare'] ??
          fareNested?['regularFare'] ??
          fareNested?['regular_fare'],
    ) ??
        defaultRegularFare;
    return ServiceQuoteEntity(
      serviceCategoryId: id,
      serviceCode: asNonEmptyString(map['serviceCode'] ?? map['code']) ?? id,
      serviceName:
          asNonEmptyString(
            map['displayName'] ?? map['serviceName'] ?? map['name'],
          ) ??
          'Ride',
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
      regularFare: regularFare,
      airportFee: airportFee < 0 ? 0 : airportFee,
      airport: airportInfo(map['airport'] ?? fareNested?['airport']) ??
          defaultAirport,
      billingMode: BookingBillingModeParsing.fromRaw(
        asNonEmptyString(
          map['billingMode'] ??
              map['billing_mode'] ??
              fareNested?['billingMode'] ??
              fareNested?['billing_mode'],
        ),
      ),
      paymentRequiredBeforeDispatch: asBool(
        map['paymentRequiredBeforeDispatch'] ??
            map['payment_required_before_dispatch'] ??
            fareNested?['paymentRequiredBeforeDispatch'] ??
            fareNested?['payment_required_before_dispatch'],
      ),
      paymentRequiredAfterCompletion: asBool(
        map['paymentRequiredAfterCompletion'] ??
            map['payment_required_after_completion'] ??
            fareNested?['paymentRequiredAfterCompletion'] ??
            fareNested?['payment_required_after_completion'],
      ),
      fareClassification: asNonEmptyString(
        map['fareClassification'] ??
            map['fare_classification'] ??
            fareNested?['fareClassification'] ??
            fareNested?['fare_classification'],
      ),
    );
  }

  static AirportQuoteEntity? airportInfo(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = asNonEmptyString(map['id'] ?? map['airportId']);
    final code = asNonEmptyString(
      map['code'] ?? map['airportCode'] ?? map['iata'],
    );
    final name = asNonEmptyString(map['name'] ?? map['airportName']);
    final tripType = asNonEmptyString(
      map['tripType'] ?? map['type'] ?? map['airportTripType'],
    );
    if (id == null && code == null && name == null && tripType == null) {
      return null;
    }
    return AirportQuoteEntity(
      id: id,
      code: code,
      name: name,
      tripType: tripType,
    );
  }

  static BookingQuoteEntity? bookingQuote(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final route = routePreview(map['route'] ?? map);
    if (route == null) return null;
    final envelopeFare = asMap(map['fare']);
    final envelopeAirport = airportInfo(
      map['airport'] ?? envelopeFare?['airport'],
    );
    final envelopeFee = asDouble(
      map['airportFee'] ??
          map['airport_fee'] ??
          envelopeFare?['airportFee'] ??
          envelopeFare?['airport_fee'],
    );
    final envelopeRegular = asDouble(
      map['regularFare'] ??
          map['regular_fare'] ??
          envelopeFare?['regularFare'] ??
          envelopeFare?['regular_fare'],
    );
    final quotesRaw = map['quotes'] ?? map['services'] ?? map['options'];
    final quotes = <ServiceQuoteEntity>[];
    if (quotesRaw is List) {
      for (final item in quotesRaw) {
        final quote = serviceQuote(
          item,
          defaultAirport: envelopeAirport,
          defaultAirportFee: envelopeFee,
          defaultRegularFare: envelopeRegular,
        );
        if (quote != null) quotes.add(quote);
      }
    }
    return BookingQuoteEntity(route: route, quotes: quotes);
  }

  static PaymentConfigEntity? paymentConfig(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final key = asNonEmptyString(
      map['publishableKey'] ?? map['publishable_key'],
    );
    final safeKey = (key != null && key.startsWith('pk_')) ? key : null;
    return PaymentConfigEntity(
      stripeEnabled: map['stripeEnabled'] == true || map['stripe_enabled'] == true,
      cardEnabled: map['cardEnabled'] == true || map['card_enabled'] == true,
      publishableKey: safeKey,
    );
  }

  static BookingPaymentEntity? bookingPayment(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final method = asNonEmptyString(
      map['paymentMethod'] ??
          map['method'] ??
          map['paymentMethodCode'] ??
          map['code'],
    );
    final status = asNonEmptyString(map['status']);
    if (method == null && status == null) return null;
    return BookingPaymentEntity(
      paymentMethod: method ?? '',
      status: status ?? '',
      paymentIntentId: asNonEmptyString(
        map['paymentIntentId'] ?? map['payment_intent_id'],
      ),
      amount: asInt(map['amount']),
      currency: asNonEmptyString(map['currency']),
      clientSecret: asNonEmptyString(
        map['clientSecret'] ?? map['client_secret'],
      ),
    );
  }

  /// Parses cash (flat booking) and card wrapper (`booking` + `payment`) safely.
  static CreateBookingResult? createBookingResult(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final nestedBooking = asMap(map['booking']);
    final nestedPayment = asMap(map['payment']);
    final parsedBooking = booking(nestedBooking ?? map);
    if (parsedBooking == null) return null;

    BookingPaymentEntity? payment;
    // Only treat sibling `payment` as Phase C card payload when a nested
    // `booking` object is present. Cash responses stay a flat booking.
    if (nestedBooking != null && nestedPayment != null) {
      final parsedPayment = bookingPayment(nestedPayment);
      final looksLikeCard =
          parsedPayment != null &&
          (parsedPayment.hasClientSecret ||
              parsedPayment.paymentIntentId != null ||
              parsedPayment.isCard);
      if (looksLikeCard) payment = parsedPayment;
    }
    return CreateBookingResult(booking: parsedBooking, payment: payment);
  }

  static PaymentMethodEntity? paymentMethod(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final code = asNonEmptyString(map['code'] ?? map['method']);
    if (code == null) return null;
    return PaymentMethodEntity(
      code: code,
      label: asNonEmptyString(map['name'] ?? map['label']) ?? code,
      isDefault: map['isDefault'] == true || map['default'] == true,
    );
  }

  /// Parses `{ success, data: [ { code, name, isActive, ... } ] }` and nested list envelopes.
  static List<PaymentMethodEntity> paymentMethods(dynamic raw) {
    final methods = <PaymentMethodEntity>[];
    for (final item in ApiResponseParser.unwrapList(raw)) {
      final method = paymentMethod(item);
      if (method != null) methods.add(method);
    }
    return methods;
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
      profileImageUrl: asNonEmptyString(
        map['profileImageUrl'] ??
            map['avatarUrl'] ??
            map['imageUrl'] ??
            map['photoUrl'],
      ),
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

  static DateTime? asDateTime(dynamic value) {
    if (value is DateTime) return value;
    final text = asNonEmptyString(value);
    if (text == null) return null;
    return DateTime.tryParse(text);
  }

  static Map<String, dynamic>? asMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static BookingVehicleEntity? bookingVehicle(dynamic raw) {
    final map = asMap(raw);
    if (map == null) return null;
    final id = asNonEmptyString(map['id'] ?? map['vehicleId']);
    final make = asNonEmptyString(map['make'] ?? map['brand']);
    final model = asNonEmptyString(map['model']);
    final color = asNonEmptyString(map['color']);
    final year = asModelYear(map['year']);
    final plate = asNonEmptyString(
      map['plateNumber'] ?? map['plate'] ?? map['maskedPlate'],
    );
    if (id == null &&
        make == null &&
        model == null &&
        color == null &&
        year == null &&
        plate == null) {
      return null;
    }
    return BookingVehicleEntity(
      id: id,
      make: make,
      model: model,
      color: color,
      year: year,
      plateNumber: plate,
    );
  }

  /// Vehicle model year. Only the booking vehicle `year` key is read.
  static int? asModelYear(dynamic value) {
    int? year;
    if (value is num) {
      year = value.round();
    } else if (value is String) {
      year = int.tryParse(value.trim());
    }
    if (year == null || year < 1950 || year > 2100) return null;
    return year;
  }

  static BookingEntity? booking(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final nestedBooking = asMap(map['booking']);
    if (nestedBooking != null &&
        asNonEmptyString(map['id'] ?? map['bookingId']) == null) {
      return booking(nestedBooking);
    }
    final id = asNonEmptyString(map['id'] ?? map['bookingId']);
    if (id == null) return null;
    final pickup = map['pickup'];
    final dropoff = map['dropoff'];
    final service = asMap(map['service']);
    final fareMap = asMap(map['fare']);
    final payment = asMap(map['payment']);
    final route = asMap(map['route']);
    final timestamps = asMap(map['timestamps']);
    final recording = asMap(map['recording']);
    final fare = asDouble(
      fareMap?['amount'] ??
          map['finalFare'] ??
          map['fare'] ??
          map['estimatedFare'] ??
          map['price'],
    );
    final encoded = asNonEmptyString(
      map['encodedPolyline'] ??
          route?['encodedPolyline'] ??
          route?['polyline'],
    );
    return BookingEntity(
      id: id,
      status: asNonEmptyString(map['status']) ?? 'created',
      bookingNumber: asNonEmptyString(
        map['bookingNumber'] ?? map['number'] ?? map['code'],
      ),
      serviceCategoryId: asNonEmptyString(
        map['serviceCategoryId'] ?? service?['serviceCategoryId'],
      ),
      serviceCode: asNonEmptyString(
        map['serviceCode'] ?? service?['serviceCode'] ?? service?['code'],
      ),
      serviceName: asNonEmptyString(
        map['serviceName'] ??
            service?['serviceName'] ??
            service?['name'] ??
            (map['service'] is String ? map['service'] : null) ??
            map['vehicleName'],
      ),
      paymentMethodCode: asNonEmptyString(
        map['paymentMethodCode'] ??
            payment?['methodCode'] ??
            payment?['code'],
      ),
      paymentMethodName: asNonEmptyString(
        map['paymentMethodName'] ??
            payment?['methodName'] ??
            payment?['name'] ??
            payment?['label'],
      ),
      paymentStatus: asNonEmptyString(
        map['paymentStatus'] ?? payment?['status'],
      ),
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
      currency: asNonEmptyString(
        fareMap?['currency'] ?? map['currency'],
      ),
      finalFare: fare,
      estimatedAmount: asDouble(
        fareMap?['estimatedAmount'] ?? map['estimatedAmount'] ?? map['estimatedFare'],
      ),
      discountAmount: asDouble(
        fareMap?['discountAmount'] ?? map['discountAmount'],
      ),
      regularFare: asDouble(
        fareMap?['regularFare'] ??
            fareMap?['regular_fare'] ??
            map['regularFare'],
      ),
      airportFee: asDouble(
        fareMap?['airportFee'] ?? fareMap?['airport_fee'] ?? map['airportFee'],
      ),
      airport: airportInfo(fareMap?['airport'] ?? map['airport']),
      driver: assignedDriver(map['driver'] ?? map['assignedDriver']),
      vehicle: bookingVehicle(map['vehicle']),
      encodedPolyline: encoded,
      distanceKm: asDouble(map['distanceKm'] ?? route?['distanceKm']),
      durationMin: asInt(map['durationMin'] ?? route?['durationMin']),
      driverEtaMinutes: () {
        final v = map['driverEtaMinutes'] ?? map['etaMinutes'];
        if (v is num) return v.round();
        if (v is String) return int.tryParse(v);
        return null;
      }(),
      recordingConsent: recordingConsent(map),
      recordingAvailable: asBool(
        recording?['available'] ?? map['recordingAvailable'],
      ),
      createdAt: asDateTime(
        map['createdAt'] ?? timestamps?['createdAt'],
      ),
      acceptedAt: asDateTime(
        map['acceptedAt'] ?? timestamps?['acceptedAt'],
      ),
      arrivedAt: asDateTime(
        map['arrivedAt'] ?? timestamps?['arrivedAt'],
      ),
      startedAt: asDateTime(
        map['startedAt'] ?? timestamps?['startedAt'],
      ),
      completedAt: asDateTime(
        map['completedAt'] ?? timestamps?['completedAt'],
      ),
      cancelledAt: asDateTime(
        map['cancelledAt'] ?? timestamps?['cancelledAt'],
      ),
      cancelledBy: asNonEmptyString(
        map['cancelledBy'] ?? timestamps?['cancelledBy'],
      ),
      cancellationReason: asNonEmptyString(
        map['cancellationReason'] ??
            map['cancelReason'] ??
            timestamps?['cancellationReason'],
      ),
      meterPayment: meterPayment(map['meterPayment'] ?? map['meter_payment']),
      billingMode: BookingBillingModeParsing.fromRaw(
        asNonEmptyString(map['billingMode'] ?? map['billing_mode']),
      ),
      paymentRequiredBeforeDispatch: asBool(
        map['paymentRequiredBeforeDispatch'] ??
            map['payment_required_before_dispatch'],
      ),
      paymentRequiredAfterCompletion: asBool(
        map['paymentRequiredAfterCompletion'] ??
            map['payment_required_after_completion'],
      ),
      fareClassification: asNonEmptyString(
        map['fareClassification'] ?? map['fare_classification'],
      ),
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

  /// GET `/passenger/bookings/:id/meter` and `meter:state` / `meter:fare`.
  ///
  /// Reads only documented backend keys (camelCase and snake_case). `meter: null`
  /// is a valid empty session. Missing optional fields stay null.
  static PassengerMeterSnapshot passengerMeter(dynamic raw) {
    if (raw is! Map) return PassengerMeterSnapshot.empty;
    final root = Map<String, dynamic>.from(raw);
    final nestedMeter = root['meter'];
    if (nestedMeter == null && root.containsKey('meter')) {
      return PassengerMeterSnapshot(
        bookingId: asNonEmptyString(
          root['bookingId'] ?? root['booking_id'],
        ),
        quotedFareUnchanged: asBool(
          root['quotedFareUnchanged'] ?? root['quoted_fare_unchanged'],
        ),
        settlement: meterSettlement(root['settlement']),
      );
    }

    final meterMap = asMap(nestedMeter) ??
        asMap(root['session']) ??
        asMap(root['meterSession']) ??
        asMap(root['meter_session']) ??
        root;
    final fareMap = asMap(meterMap['fare']) ??
        asMap(meterMap['fareBreakdown']) ??
        asMap(meterMap['fare_breakdown']) ??
        asMap(root['fareBreakdown']) ??
        asMap(root['fare_breakdown']) ??
        asMap(root['fare']);
    final fareLooksLikeBreakdown = fareMap != null &&
        (fareMap.containsKey('flagDropCents') ||
            fareMap.containsKey('flag_drop_cents') ||
            fareMap.containsKey('distanceChargeCents') ||
            fareMap.containsKey('distance_charge_cents') ||
            fareMap.containsKey('waitingChargeCents') ||
            fareMap.containsKey('waiting_charge_cents') ||
            fareMap.containsKey('totalCents') ||
            fareMap.containsKey('total_cents'));
    final fareMoney = _meterMoney(
      fareMap?['provisionalFare'] ??
          fareMap?['provisional_fare'] ??
          (fareLooksLikeBreakdown ? null : fareMap?['amount']) ??
          meterMap['provisionalFare'] ??
          meterMap['provisional_fare'] ??
          meterMap['frozenFare'] ??
          meterMap['frozen_fare'] ??
          (meterMap['fare'] is Map ? null : meterMap['fare']) ??
          root['provisionalFare'] ??
          root['provisional_fare'] ??
          (root['fare'] is Map ? null : root['fare']),
    );

    return PassengerMeterSnapshot(
      bookingId: asNonEmptyString(
        meterMap['bookingId'] ??
            meterMap['booking_id'] ??
            root['bookingId'] ??
            root['booking_id'],
      ),
      sessionId: asNonEmptyString(
        meterMap['sessionId'] ??
            meterMap['session_id'] ??
            meterMap['id'] ??
            meterMap['meterSessionId'] ??
            meterMap['meter_session_id'] ??
            root['sessionId'] ??
            root['session_id'],
      ),
      sessionType: asNonEmptyString(
        meterMap['sessionType'] ??
            meterMap['session_type'] ??
            meterMap['origin'] ??
            meterMap['meterType'] ??
            meterMap['meter_type'] ??
            root['sessionType'] ??
            root['session_type'] ??
            root['origin'],
      ),
      status: SoftMeterStatusParsing.fromRaw(
        asNonEmptyString(
          meterMap['status'] ?? root['status'] ?? meterMap['meterStatus'],
        ),
      ),
      stateVersion: asInt(
        meterMap['stateVersion'] ??
            meterMap['state_version'] ??
            root['stateVersion'] ??
            root['state_version'],
      ),
      fareFrozen: asBool(
        meterMap['fareFrozen'] ??
            meterMap['fare_frozen'] ??
            root['fareFrozen'] ??
            root['fare_frozen'],
      ),
      reviewRequired: asBool(
        meterMap['reviewRequired'] ??
            meterMap['review_required'] ??
            root['reviewRequired'] ??
            root['review_required'],
      ),
      provisionalFare: fareMoney.amount,
      currency: fareMoney.currency ??
          asNonEmptyString(
            meterMap['currency'] ?? root['currency'],
          ),
      traveledDistanceMiles: asDouble(
        meterMap['traveledDistanceMiles'] ??
            meterMap['traveled_distance_miles'] ??
            meterMap['distanceMiles'] ??
            meterMap['distance_miles'] ??
            meterMap['traveledMiles'] ??
            meterMap['traveled_miles'] ??
            root['traveledDistanceMiles'] ??
            root['traveled_distance_miles'],
      ),
      tripElapsedSeconds: _elapsedSeconds(
        meterMap['tripElapsedSeconds'] ??
            meterMap['trip_elapsed_seconds'] ??
            meterMap['tripElapsedTime'] ??
            meterMap['trip_elapsed_time'] ??
            root['tripElapsedSeconds'] ??
            root['trip_elapsed_seconds'],
      ),
      chargeableElapsedSeconds: _elapsedSeconds(
        meterMap['chargeableElapsedSeconds'] ??
            meterMap['chargeable_elapsed_seconds'] ??
            meterMap['chargeableElapsedTime'] ??
            meterMap['chargeable_elapsed_time'] ??
            root['chargeableElapsedSeconds'] ??
            root['chargeable_elapsed_seconds'],
      ),
      pauseDurationSeconds: _elapsedSeconds(
        meterMap['pauseDurationSeconds'] ??
            meterMap['pause_duration_seconds'] ??
            meterMap['pauseDuration'] ??
            meterMap['pause_duration'] ??
            root['pauseDurationSeconds'] ??
            root['pause_duration_seconds'],
      ),
      quotedFareUnchanged: asBool(
        root['quotedFareUnchanged'] ??
            root['quoted_fare_unchanged'] ??
            meterMap['quotedFareUnchanged'] ??
            meterMap['quoted_fare_unchanged'],
      ),
      settlement: meterSettlement(
        root['settlement'] ?? meterMap['settlement'],
      ),
      eligibleStoppedSeconds: asInt(
        meterMap['eligibleStoppedSeconds'] ??
            meterMap['eligible_stopped_seconds'] ??
            root['eligibleStoppedSeconds'] ??
            root['eligible_stopped_seconds'],
      ),
      waitingSeconds: asInt(
        meterMap['waitingSeconds'] ??
            meterMap['waiting_seconds'] ??
            root['waitingSeconds'] ??
            root['waiting_seconds'],
      ),
      excludedStopSeconds: asInt(
        meterMap['excludedStopSeconds'] ??
            meterMap['excluded_stop_seconds'] ??
            root['excludedStopSeconds'] ??
            root['excluded_stop_seconds'],
      ),
      stopStreak: asInt(
        meterMap['stopStreak'] ??
            meterMap['stop_streak'] ??
            root['stopStreak'] ??
            root['stop_streak'],
      ),
      stopPolicy: _stopPolicy(
        meterMap['stopPolicy'] ??
            meterMap['stop_policy'] ??
            root['stopPolicy'] ??
            root['stop_policy'],
      ),
      flagDropCents: asInt(
        fareMap?['flagDropCents'] ??
            fareMap?['flag_drop_cents'] ??
            meterMap['flagDropCents'] ??
            meterMap['flag_drop_cents'] ??
            root['flagDropCents'] ??
            root['flag_drop_cents'],
      ),
      distanceChargeCents: asInt(
        fareMap?['distanceChargeCents'] ??
            fareMap?['distance_charge_cents'] ??
            meterMap['distanceChargeCents'] ??
            meterMap['distance_charge_cents'] ??
            root['distanceChargeCents'] ??
            root['distance_charge_cents'],
      ),
      waitingChargeCents: asInt(
        fareMap?['waitingChargeCents'] ??
            fareMap?['waiting_charge_cents'] ??
            meterMap['waitingChargeCents'] ??
            meterMap['waiting_charge_cents'] ??
            root['waitingChargeCents'] ??
            root['waiting_charge_cents'],
      ),
      totalCents: asInt(
        fareMap?['totalCents'] ??
            fareMap?['total_cents'] ??
            meterMap['totalCents'] ??
            meterMap['total_cents'] ??
            root['totalCents'] ??
            root['total_cents'],
      ),
      billedStoppedMinutes: asInt(
        fareMap?['billedStoppedMinutes'] ??
            fareMap?['billed_stopped_minutes'] ??
            meterMap['billedStoppedMinutes'] ??
            meterMap['billed_stopped_minutes'] ??
            root['billedStoppedMinutes'] ??
            root['billed_stopped_minutes'],
      ),
      unbilledStoppedRemainderSeconds: asInt(
        fareMap?['unbilledStoppedRemainderSeconds'] ??
            fareMap?['unbilled_stopped_remainder_seconds'] ??
            meterMap['unbilledStoppedRemainderSeconds'] ??
            meterMap['unbilled_stopped_remainder_seconds'] ??
            root['unbilledStoppedRemainderSeconds'] ??
            root['unbilled_stopped_remainder_seconds'],
      ),
      waitingPolicyApplied: asBool(
        fareMap?['waitingPolicyApplied'] ??
            fareMap?['waiting_policy_applied'] ??
            meterMap['waitingPolicyApplied'] ??
            meterMap['waiting_policy_applied'] ??
            root['waitingPolicyApplied'] ??
            root['waiting_policy_applied'],
      ),
      distanceTimePolicyApplied: asBool(
        fareMap?['distanceTimePolicyApplied'] ??
            fareMap?['distance_time_policy_applied'] ??
            meterMap['distanceTimePolicyApplied'] ??
            meterMap['distance_time_policy_applied'] ??
            root['distanceTimePolicyApplied'] ??
            root['distance_time_policy_applied'],
      ),
    );
  }

  static MeterSettlement? meterSettlement(dynamic raw) {
    final map = asMap(raw);
    if (map == null) return null;
    final billable = asBool(map['billable']);
    final charged = asBool(
      map['charged'] ?? map['isCharged'] ?? map['is_charged'],
    );
    final status = asNonEmptyString(map['status']);
    if (billable == null && charged == null && status == null) return null;
    return MeterSettlement(
      billable: billable,
      charged: charged,
      status: status,
    );
  }

  static ({double? amount, String? currency}) _meterMoney(dynamic raw) {
    if (raw == null) return (amount: null, currency: null);
    if (raw is num || raw is String) {
      return (amount: asDouble(raw), currency: null);
    }
    final map = asMap(raw);
    if (map == null) return (amount: null, currency: null);
    return (
      amount: asDouble(
        map['amount'] ??
            map['value'] ??
            map['provisionalFare'] ??
            map['provisional_fare'],
      ),
      currency: asNonEmptyString(map['currency'] ?? map['code']),
    );
  }

  static String? _stopPolicy(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return asNonEmptyString(raw);
    final map = asMap(raw);
    if (map == null) return null;
    return asNonEmptyString(
      map['name'] ?? map['label'] ?? map['id'] ?? map['code'],
    );
  }

  /// POST meter-payment/payment-intent. Client secret stays off the UI record.
  ///
  /// Accepts the backend top-level payload and a `{ success, data }` envelope.
  static MeterPaymentIntentResult meterPaymentIntent(dynamic raw) {
    if (raw is! Map) return const MeterPaymentIntentResult();
    final root = _unwrapSuccessData(Map<String, dynamic>.from(raw));
    final key = asNonEmptyString(
      root['publishableKey'] ?? root['publishable_key'],
    );
    return MeterPaymentIntentResult(
      record: meterPayment(root),
      clientSecret: _paymentIntentClientSecret(root),
      paymentIntentId: _paymentIntentId(root),
      publishableKey: (key != null && key.startsWith('pk_')) ? key : null,
    );
  }

  static Map<String, dynamic> _unwrapSuccessData(Map<String, dynamic> root) {
    final data = asMap(root['data']);
    if (data == null) return root;
    final looksLikeIntent =
        data.containsKey('paymentIntentClientSecret') ||
        data.containsKey('payment_intent_client_secret') ||
        data.containsKey('clientSecret') ||
        data.containsKey('client_secret') ||
        data.containsKey('paymentIntentId') ||
        data.containsKey('publishableKey') ||
        data.containsKey('finalFareCents') ||
        data.containsKey('bookingId');
    if (!looksLikeIntent) return root;
    return data;
  }

  static String? _paymentIntentClientSecret(Map<String, dynamic> root) {
    final direct = asNonEmptyString(
      root['paymentIntentClientSecret'] ??
          root['payment_intent_client_secret'] ??
          root['clientSecret'] ??
          root['client_secret'],
    );
    if (direct != null) return direct;
    for (final key in [
      'payment',
      'paymentIntent',
      'payment_intent',
      'intent',
      'meterPayment',
      'meter_payment',
    ]) {
      final nested = asMap(root[key]);
      if (nested == null) continue;
      final secret = asNonEmptyString(
        nested['paymentIntentClientSecret'] ??
            nested['payment_intent_client_secret'] ??
            nested['clientSecret'] ??
            nested['client_secret'],
      );
      if (secret != null) return secret;
      final deeper = _paymentIntentClientSecret(nested);
      if (deeper != null) return deeper;
    }
    return null;
  }

  static String? _paymentIntentId(Map<String, dynamic> root) {
    final direct = asNonEmptyString(
      root['paymentIntentId'] ?? root['payment_intent_id'],
    );
    if (direct != null) return direct;
    for (final key in [
      'payment',
      'paymentIntent',
      'payment_intent',
      'intent',
      'meterPayment',
      'meter_payment',
    ]) {
      final nested = asMap(root[key]);
      if (nested == null) continue;
      final id = asNonEmptyString(
        nested['paymentIntentId'] ??
            nested['payment_intent_id'] ??
            nested['id'],
      );
      if (id != null && id.startsWith('pi_')) return id;
      final deeper = _paymentIntentId(nested);
      if (deeper != null) return deeper;
    }
    return null;
  }

  /// GET meter-payment, receipt, unpaid, and `booking:meter_payment`.
  static MeterPaymentRecord? meterPayment(dynamic raw) {
    if (raw is! Map) return null;
    final root = Map<String, dynamic>.from(raw);
    final nested = asMap(root['meterPayment'] ?? root['meter_payment']);
    if (nested != null) {
      final parsed = meterPayment(nested);
      if (parsed == null) return _meterPaymentFromMap(root);
      final hostedUrl = asNonEmptyString(
        root['hostedUrl'] ??
            root['hosted_url'] ??
            root['checkoutUrl'] ??
            root['checkout_url'] ??
            root['url'],
      );
      if (hostedUrl != null &&
          (parsed.hostedUrl == null || parsed.hostedUrl!.isEmpty)) {
        return parsed.copyWith(hostedUrl: hostedUrl);
      }
      return parsed;
    }
    return _meterPaymentFromMap(root);
  }

  static MeterPaymentRecord? _meterPaymentFromMap(Map<String, dynamic> root) {
    final payment = asMap(root['payment']);
    final fare = asMap(root['fare']) ??
        asMap(root['fareBreakdown']) ??
        asMap(root['fare_breakdown']);
    final paymentStatusRaw = asNonEmptyString(
      root['paymentStatus'] ??
          root['payment_status'] ??
          payment?['status'] ??
          payment?['paymentStatus'] ??
          root['status'],
    );
    final paymentMode = asNonEmptyString(
      root['paymentMode'] ??
          root['payment_mode'] ??
          payment?['mode'] ??
          payment?['paymentMode'],
    );
    final fareClassification = asNonEmptyString(
      root['fareClassification'] ??
          root['fare_classification'] ??
          fare?['classification'] ??
          fare?['fareClassification'],
    );
    final meterSessionId = asNonEmptyString(
      root['meterSessionId'] ??
          root['meter_session_id'] ??
          root['sessionId'] ??
          root['session_id'],
    );
    final finalFareCents = asInt(
      root['finalFareCents'] ??
          root['final_fare_cents'] ??
          fare?['finalFareCents'] ??
          fare?['final_fare_cents'] ??
          fare?['totalCents'] ??
          fare?['total_cents'],
    );
    final paymentRequired = asBool(
      root['paymentRequired'] ?? root['payment_required'],
    );
    final paymentVersion = asInt(
      root['paymentVersion'] ?? root['payment_version'],
    );
    final hostedUrl = asNonEmptyString(
      root['hostedUrl'] ??
          root['hosted_url'] ??
          root['checkoutUrl'] ??
          root['checkout_url'] ??
          root['url'],
    );
    final receiptAvailable = asBool(
      root['receiptAvailable'] ?? root['receipt_available'],
    );
    final receiptUrl = asNonEmptyString(
      root['receiptUrl'] ?? root['receipt_url'],
    );
    final testMode = asBool(root['testMode'] ?? root['test_mode']);
    final productionCharge = asBool(
      root['productionCharge'] ?? root['production_charge'],
    );
    final status = MeterPaymentStatusParsing.fromRaw(paymentStatusRaw);
    final hasMeterSignal =
        _looksLikeMeterValue(paymentMode) ||
        _looksLikeMeterValue(fareClassification) ||
        (meterSessionId != null && meterSessionId.isNotEmpty) ||
        finalFareCents != null ||
        paymentRequired != null ||
        paymentVersion != null ||
        hostedUrl != null ||
        receiptAvailable != null ||
        receiptUrl != null ||
        testMode != null ||
        productionCharge != null ||
        status != MeterPaymentStatus.unknown;
    if (!hasMeterSignal) return null;

    final record = MeterPaymentRecord(
      bookingId: asNonEmptyString(
        root['bookingId'] ??
            root['booking_id'] ??
            asMap(root['booking'])?['id'] ??
            asMap(root['booking'])?['bookingId'] ??
            root['id'],
      ),
      rideStatus: asNonEmptyString(
        root['rideStatus'] ?? root['ride_status'],
      ),
      paymentStatus: status,
      paymentStatusRaw: paymentStatusRaw,
      paymentRequired: paymentRequired,
      paymentMode: paymentMode,
      finalFareCents: finalFareCents,
      currency: asNonEmptyString(
        root['currency'] ?? fare?['currency'] ?? payment?['currency'],
      ),
      meterSessionId: meterSessionId,
      completedAt: asDateTime(
        root['completedAt'] ?? root['completed_at'],
      ),
      paidAt: asDateTime(root['paidAt'] ?? root['paid_at']),
      receiptAvailable: receiptAvailable,
      receiptUrl: receiptUrl,
      hostedUrl: hostedUrl,
      testMode: testMode,
      fareClassification: fareClassification,
      paymentVersion: paymentVersion,
      productionCharge: productionCharge,
      flagDropCents: asInt(
        root['flagDropCents'] ??
            root['flag_drop_cents'] ??
            fare?['flagDropCents'] ??
            fare?['flag_drop_cents'],
      ),
      distanceChargeCents: asInt(
        root['distanceChargeCents'] ??
            root['distance_charge_cents'] ??
            fare?['distanceChargeCents'] ??
            fare?['distance_charge_cents'],
      ),
      waitingChargeCents: asInt(
        root['waitingChargeCents'] ??
            root['waiting_charge_cents'] ??
            fare?['waitingChargeCents'] ??
            fare?['waiting_charge_cents'],
      ),
      totalCents: asInt(
        root['totalCents'] ??
            root['total_cents'] ??
            fare?['totalCents'] ??
            fare?['total_cents'],
      ),
    );
    return record.hasRecord ? record : null;
  }

  static bool _looksLikeMeterValue(String? raw) {
    final value = raw?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return false;
    return value.contains('meter') || value.contains('soft');
  }

  static int? _elapsedSeconds(dynamic raw) {
    if (raw == null) return null;
    if (raw is Duration) return raw.inSeconds;
    final asNumber = asInt(raw);
    if (asNumber != null) return asNumber;
    final text = asNonEmptyString(raw);
    if (text == null) return null;
    final parts = text.split(':');
    if (parts.length == 2 || parts.length == 3) {
      final nums = parts.map(int.tryParse).toList();
      if (nums.contains(null)) return null;
      if (parts.length == 2) {
        return nums[0]! * 60 + nums[1]!;
      }
      return nums[0]! * 3600 + nums[1]! * 60 + nums[2]!;
    }
    return null;
  }
}
