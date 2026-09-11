import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/passenger_api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../../../core/payments/stripe_debug.dart';
import '../../domain/entities/pickup_spot_entity.dart';
import '../../domain/entities/ride_planning_entities.dart';
import '../utils/booking_create_request.dart';
import '../utils/ride_planning_parsers.dart';

abstract interface class PassengerRideRemoteDatasource {
  Future<PlaceEntity?> reverseGeocode({
    required double lat,
    required double lng,
  });

  Future<List<PlacePredictionEntity>> autocomplete({
    required String input,
    double? lat,
    double? lng,
    String? city,
    String? country,
    String? sessionToken,
    CancelToken? cancelToken,
  });

  Future<PlaceEntity?> placeDetails({
    required String placeId,
    String? sessionToken,
  });

  Future<List<PlacePredictionEntity>> placeSuggestions({
    double? lat,
    double? lng,
  });

  Future<List<PickupSpotEntity>> pickupSpots({
    required double lat,
    required double lng,
    String? address,
  });

  Future<List<NearbyDriverEntity>> nearbyDrivers({
    required double lat,
    required double lng,
    required String serviceCategoryId,
    double? radiusKm,
  });

  Future<RoutePreviewEntity> previewRoute({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    String travelMode = 'DRIVE',
    String routePreference = 'TRAFFIC_AWARE',
  });

  Future<BookingQuoteEntity> quoteBooking({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  });

  Future<List<PaymentMethodEntity>> paymentMethods();

  Future<PaymentConfigEntity> paymentConfig();

  Future<CreateBookingResult> createBooking({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    required String idempotencyKey,
    String schedulingType = 'instant',
  });

  Future<BookingPaymentEntity> bookingPayment(String bookingId);

  Future<BookingEntity?> activeBooking();

  Future<BookingEntity?> bookingById(String bookingId);

  Future<BookingEntity?> cancelBooking(
    String bookingId, {
    String? reason,
    String? idempotencyKey,
  });

  Future<RecordingConsentResult> submitRecordingConsent({
    required String bookingId,
    required bool consent,
  });
}

class PassengerRideRemoteDatasourceImpl
    implements PassengerRideRemoteDatasource {
  PassengerRideRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PlaceEntity?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.reverseGeocode,
        queryParameters: {'lat': lat, 'lng': lng},
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      // Some APIs nest place under data.place / data.result.
      final placeRaw = data['place'] ?? data['result'] ?? data;
      return RidePlanningParsers.place(placeRaw) ??
          PlaceEntity(
            placeId:
                RidePlanningParsers.asNonEmptyString(data['placeId']) ?? '',
            label:
                RidePlanningParsers.asNonEmptyString(
                  data['label'] ?? data['address'],
                ) ??
                'Current location',
            address:
                RidePlanningParsers.asNonEmptyString(data['address']) ??
                '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
            latitude: lat,
            longitude: lng,
            city: RidePlanningParsers.asNonEmptyString(data['city']),
            district: RidePlanningParsers.asNonEmptyString(data['district']),
            postalCode: RidePlanningParsers.asNonEmptyString(
              data['postalCode'],
            ),
          );
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<PlacePredictionEntity>> autocomplete({
    required String input,
    double? lat,
    double? lng,
    String? city,
    String? country,
    String? sessionToken,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.autocomplete,
        queryParameters: {
          'input': input,
          'lat': ?lat,
          'lng': ?lng,
          if (city != null && city.isNotEmpty) 'city': city,
          if (country != null && country.isNotEmpty) 'country': country,
          if (sessionToken != null && sessionToken.isNotEmpty)
            'sessionToken': sessionToken,
        },
        cancelToken: cancelToken,
      );
      if (kDebugMode) {
        debugPrint(
          'PassengerAutocomplete: HTTP ${response.statusCode} '
          'path=${PassengerApiPaths.autocomplete}',
        );
      }
      _throwIfFailed(response.data);
      final parsed = _parsePredictionList(response.data);
      if (kDebugMode) {
        debugPrint('PassengerAutocomplete: parsed=${parsed.length}');
      }
      return parsed;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<PlaceEntity?> placeDetails({
    required String placeId,
    String? sessionToken,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.placeDetails,
        queryParameters: {
          'placeId': placeId,
          if (sessionToken != null && sessionToken.isNotEmpty)
            'sessionToken': sessionToken,
        },
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      return RidePlanningParsers.place(data['place'] ?? data['result'] ?? data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<PlacePredictionEntity>> placeSuggestions({
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.placeSuggestions,
        queryParameters: {'lat': ?lat, 'lng': ?lng},
      );
      _throwIfFailed(response.data);
      return _parsePredictionList(response.data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<PickupSpotEntity>> pickupSpots({
    required double lat,
    required double lng,
    String? address,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.pickupSpots,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          if (address != null && address.isNotEmpty) 'address': address,
        },
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      final listRaw = data['spots'] ?? data['pickupSpots'] ?? data['items'];
      final spots = <PickupSpotEntity>[];
      if (listRaw is List) {
        for (var i = 0; i < listRaw.length; i++) {
          final item = listRaw[i];
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item);
          final label =
              RidePlanningParsers.asNonEmptyString(
                map['label'] ??
                    map['spotLabel'] ??
                    map['address'] ??
                    map['name'],
              ) ??
              'Selected pickup';
          spots.add(
            PickupSpotEntity(
              index: i,
              label: label,
              id: RidePlanningParsers.asNonEmptyString(map['id']),
              latitude: RidePlanningParsers.asDouble(
                map['latitude'] ?? map['lat'],
              ),
              longitude: RidePlanningParsers.asDouble(
                map['longitude'] ?? map['lng'],
              ),
              address: RidePlanningParsers.asNonEmptyString(map['address']),
              source: RidePlanningParsers.asNonEmptyString(map['source']),
            ),
          );
        }
      }
      if (spots.isEmpty) {
        spots.add(
          PickupSpotEntity(
            index: 0,
            label: address?.trim().isNotEmpty == true
                ? address!.trim()
                : 'Selected pickup',
            latitude: lat,
            longitude: lng,
            address: address,
            source: 'selected_location',
          ),
        );
      }
      return spots;
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<NearbyDriverEntity>> nearbyDrivers({
    required double lat,
    required double lng,
    required String serviceCategoryId,
    double? radiusKm,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.nearbyDrivers,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'serviceCategoryId': serviceCategoryId,
          'radiusKm': ?radiusKm,
        },
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      final listRaw = data['drivers'] ?? data['items'] ?? data['nearby'];
      final drivers = <NearbyDriverEntity>[];
      if (listRaw is List) {
        for (final item in listRaw) {
          final driver = RidePlanningParsers.nearbyDriver(item);
          if (driver != null) drivers.add(driver);
        }
      }
      return drivers;
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<RoutePreviewEntity> previewRoute({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    String travelMode = 'DRIVE',
    String routePreference = 'TRAFFIC_AWARE',
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('════════ ROUTE PREVIEW ════════');
        debugPrint('POST ${PassengerApiPaths.routePreview}');
      }
      final response = await _apiClient.dio.post<dynamic>(
        PassengerApiPaths.routePreview,
        data: {
          'pickup': pickup.toJson(),
          'dropoff': dropoff.toJson(),
          'stops': stops.map((s) => s.toJson()).toList(),
          'travelMode': travelMode,
          'routePreference': routePreference,
        },
      );
      if (kDebugMode) {
        debugPrint('Status: ${response.statusCode}');
      }
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      final route = RidePlanningParsers.routePreview(data['route'] ?? data);
      if (route == null) {
        throw const PassengerApiException('Invalid route preview response.');
      }
      return route;
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<BookingQuoteEntity> quoteBooking({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('════════ BOOKING QUOTE ════════');
        debugPrint('POST ${PassengerApiPaths.bookingQuote}');
      }
      final response = await _apiClient.dio.post<dynamic>(
        PassengerApiPaths.bookingQuote,
        data: {
          'pickup': pickup.toJson(),
          'dropoff': dropoff.toJson(),
          'stops': stops.map((s) => s.toJson()).toList(),
        },
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      final quote = RidePlanningParsers.bookingQuote(data);
      if (quote == null) {
        throw const PassengerApiException('Invalid booking quote response.');
      }
      return quote;
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<List<PaymentMethodEntity>> paymentMethods() async {
    final url = StripeDebug.requestUrl(
      _apiClient.dio,
      PassengerApiPaths.paymentMethods,
    );
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.paymentMethods,
      );
      StripeDebug.httpGet(
        url: url,
        status: response.statusCode,
        body: response.data,
      );
      _throwIfFailed(response.data);
      final methods = RidePlanningParsers.paymentMethods(response.data);
      final codes = methods.map((m) => m.code).toList();
      StripeDebug.paymentMethodsParsed(
        codes: codes,
        cardReturnedByBackend: CardBookingPayment.backendIncludesCard(methods),
      );
      return methods;
    } on DioException catch (e) {
      _logStripeApiError(url, e);
      throw PassengerApiErrorMapper.fromDio(e);
    } catch (e) {
      _logStripeApiError(url, e);
      rethrow;
    }
  }

  @override
  Future<PaymentConfigEntity> paymentConfig() async {
    final url = StripeDebug.requestUrl(
      _apiClient.dio,
      PassengerApiPaths.paymentsConfig,
    );
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.paymentsConfig,
      );
      StripeDebug.httpGet(
        url: url,
        status: response.statusCode,
        body: response.data,
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      final config =
          RidePlanningParsers.paymentConfig(data) ??
          const PaymentConfigEntity(stripeEnabled: false, cardEnabled: false);
      StripeDebug.paymentConfigParsed(
        stripeEnabled: config.stripeEnabled,
        cardEnabled: config.cardEnabled,
        publishableKey: config.publishableKey,
      );
      return config;
    } on DioException catch (e) {
      _logStripeApiError(url, e);
      throw PassengerApiErrorMapper.fromDio(e);
    } catch (e) {
      _logStripeApiError(url, e);
      rethrow;
    }
  }

  @override
  Future<CreateBookingResult> createBooking({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    required String idempotencyKey,
    String schedulingType = 'instant',
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('════════ CREATE BOOKING ════════');
        debugPrint('POST ${PassengerApiPaths.bookings}');
        debugPrint('Idempotency-Key: $idempotencyKey');
        debugPrint('paymentMethodCode: $paymentMethodCode');
      }
      final response = await _apiClient.dio.post<dynamic>(
        PassengerApiPaths.bookings,
        data: BookingCreateRequest.body(
          serviceCategoryId: serviceCategoryId,
          pickup: pickup,
          dropoff: dropoff,
          stops: stops,
          paymentMethodCode: paymentMethodCode,
          schedulingType: schedulingType,
        ),
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      StripeDebug.httpPost(
        url: StripeDebug.requestUrl(_apiClient.dio, PassengerApiPaths.bookings),
        status: response.statusCode,
        body: response.data,
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      final result = RidePlanningParsers.createBookingResult(data);
      if (result == null) {
        throw const PassengerApiException('Invalid create booking response.');
      }
      StripeDebug.createBookingResult(
        bookingId: result.booking.id,
        bookingStatus: result.booking.status,
        paymentMethod:
            result.payment?.paymentMethod ?? result.booking.paymentMethodCode,
        paymentStatus: result.payment?.status,
        paymentIntentId: result.payment?.paymentIntentId,
        clientSecretPresent: result.payment?.hasClientSecret == true,
      );
      return result;
    } on DioException catch (e) {
      _logStripeApiError(
        StripeDebug.requestUrl(_apiClient.dio, PassengerApiPaths.bookings),
        e,
      );
      throw PassengerApiErrorMapper.fromDio(e);
    } catch (e) {
      _logStripeApiError(
        StripeDebug.requestUrl(_apiClient.dio, PassengerApiPaths.bookings),
        e,
      );
      rethrow;
    }
  }

  @override
  Future<BookingPaymentEntity> bookingPayment(String bookingId) async {
    final url = StripeDebug.requestUrl(
      _apiClient.dio,
      PassengerApiPaths.bookingPayment(bookingId),
    );
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.bookingPayment(bookingId),
      );
      StripeDebug.httpGet(
        url: url,
        status: response.statusCode,
        body: response.data,
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      final payment = RidePlanningParsers.bookingPayment(data);
      if (payment == null) {
        throw const PassengerApiException('Invalid booking payment response.');
      }
      StripeDebug.paymentStatus(
        attempt: StripeDebug.pollAttempt,
        bookingId: bookingId,
        status: payment.status,
        paymentIntentId: payment.paymentIntentId,
        clientSecretPresent: payment.hasClientSecret,
      );
      return payment;
    } on DioException catch (e) {
      _logStripeApiError(url, e);
      throw PassengerApiErrorMapper.fromDio(e);
    } catch (e) {
      _logStripeApiError(url, e);
      rethrow;
    }
  }

  @override
  Future<BookingEntity?> activeBooking() async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.activeBooking,
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      return RidePlanningParsers.booking(data['booking'] ?? data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<BookingEntity?> bookingById(String bookingId) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.bookingById(bookingId),
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      return RidePlanningParsers.booking(data['booking'] ?? data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<BookingEntity?> cancelBooking(
    String bookingId, {
    String? reason,
    String? idempotencyKey,
  }) async {
    try {
      final headers = <String, dynamic>{};
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
        headers['Idempotency-Key'] = idempotencyKey;
      }
      final response = await _apiClient.dio.post<dynamic>(
        PassengerApiPaths.cancelBooking(bookingId),
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
        options: headers.isEmpty ? null : Options(headers: headers),
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      return RidePlanningParsers.booking(data['booking'] ?? data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<RecordingConsentResult> submitRecordingConsent({
    required String bookingId,
    required bool consent,
  }) async {
    try {
      final response = await _apiClient.dio.post<dynamic>(
        PassengerApiPaths.recordingConsent(bookingId),
        data: {'consent': consent},
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      return RidePlanningParsers.recordingConsentResult(
            data,
            requestedConsent: consent,
          ) ??
          RecordingConsentResult(consent: consent);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  List<PlacePredictionEntity> _parsePredictionList(dynamic raw) {
    final listRaw = ApiResponseParser.unwrapList(raw);
    final out = <PlacePredictionEntity>[];
    for (final item in listRaw) {
      final prediction = RidePlanningParsers.prediction(item);
      if (prediction != null) out.add(prediction);
    }
    return out;
  }

  void _throwIfFailed(dynamic raw) {
    final error = PassengerApiErrorMapper.fromEnvelope(raw);
    if (error != null) throw error;
  }

  void _logStripeApiError(String endpoint, Object error) {
    if (error is DioException) {
      StripeDebug.apiError(
        endpoint: endpoint,
        statusCode: error.response?.statusCode,
        responseBody: error.response?.data,
        exceptionType: error.type.name,
        error: error.message,
      );
      return;
    }
    StripeDebug.apiError(
      endpoint: endpoint,
      exceptionType: error.runtimeType.toString(),
      error: error is PassengerApiException ? error.code ?? error.message : null,
    );
  }
}
