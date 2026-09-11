import 'package:dio/dio.dart';

import '../../domain/entities/fare_estimate_entity.dart';
import '../../domain/entities/pickup_spot_entity.dart';
import '../../domain/entities/ride_booking_entity.dart';
import '../../domain/entities/ride_destination_entity.dart';
import '../../domain/entities/ride_option_entity.dart';
import '../../domain/entities/ride_planning_entities.dart';
import '../../domain/repositories/ride_booking_repository.dart';
import '../datasources/passenger_ride_remote_datasource.dart';
import '../datasources/ride_booking_local_datasource.dart';
import '../datasources/ride_booking_remote_datasource.dart';

class RideBookingRepositoryImpl implements RideBookingRepository {
  RideBookingRepositoryImpl({
    required RideBookingLocalDatasource localDatasource,
    required RideBookingRemoteDatasource remoteDatasource,
    required PassengerRideRemoteDatasource passengerRemoteDatasource,
  }) : _local = localDatasource,
       _remote = remoteDatasource,
       _passenger = passengerRemoteDatasource;

  final RideBookingLocalDatasource _local;
  final RideBookingRemoteDatasource _remote;
  final PassengerRideRemoteDatasource _passenger;

  @override
  String getDefaultPickupLocation() => '';

  @override
  Future<List<RideDestinationEntity>> getSuggestedLocations() async {
    // Live suggestions come from place autocomplete; do not surface local fixtures.
    return const [];
  }

  @override
  Future<RideDestinationEntity?> findDestinationById(String id) async {
    return null;
  }

  @override
  Future<List<RideOptionEntity>> getRideOptions() async {
    // Live options come from POST /bookings/quote only.
    return const [];
  }

  @override
  Future<RideOptionEntity?> findRideOptionById(String id) async {
    return null;
  }

  @override
  Future<List<PickupSpotEntity>> getPickupSpots() async {
    return const [];
  }

  @override
  String pickupSpotLabel(int index) {
    return '';
  }

  @override
  Future<FareEstimateEntity> estimateFare({
    required String rideType,
    required String optionId,
  }) async {
    final option = await findRideOptionById(optionId);
    if (option == null) {
      return const FareEstimateEntity(displayFare: 'BDT 0.00');
    }
    return FareEstimateEntity(displayFare: option.price);
  }

  @override
  Future<void> confirmPickup({required RideBookingEntity booking}) {
    return _local.simulateConfirmPickupDelay();
  }

  @override
  Future<String> createRideRequest({required RideBookingEntity booking}) {
    return _local.simulateCreateRideRequest();
  }

  @override
  Future<String> createRideDraft() async {
    final draft = await _remote.createDraft();
    return draft.id;
  }

  @override
  Future<void> confirmRide({required String rideDraftId}) {
    return _remote.confirm(rideDraftId);
  }

  @override
  Future<PlaceEntity?> reverseGeocode({
    required double lat,
    required double lng,
  }) => _passenger.reverseGeocode(lat: lat, lng: lng);

  @override
  Future<List<PlacePredictionEntity>> autocomplete({
    required String input,
    double? lat,
    double? lng,
    String? city,
    String? country,
    String? sessionToken,
    dynamic cancelToken,
  }) => _passenger.autocomplete(
    input: input,
    lat: lat,
    lng: lng,
    city: city,
    country: country,
    sessionToken: sessionToken,
    cancelToken: cancelToken is CancelToken ? cancelToken : null,
  );

  @override
  Future<PlaceEntity?> placeDetails({
    required String placeId,
    String? sessionToken,
  }) => _passenger.placeDetails(placeId: placeId, sessionToken: sessionToken);

  @override
  Future<List<PlacePredictionEntity>> placeSuggestions({
    double? lat,
    double? lng,
  }) => _passenger.placeSuggestions(lat: lat, lng: lng);

  @override
  Future<List<PickupSpotEntity>> fetchPickupSpots({
    required double lat,
    required double lng,
    String? address,
  }) => _passenger.pickupSpots(lat: lat, lng: lng, address: address);

  @override
  Future<List<NearbyDriverEntity>> nearbyDrivers({
    required double lat,
    required double lng,
    required String serviceCategoryId,
    double? radiusKm,
  }) => _passenger.nearbyDrivers(
    lat: lat,
    lng: lng,
    serviceCategoryId: serviceCategoryId,
    radiusKm: radiusKm,
  );

  @override
  Future<RoutePreviewEntity> previewRoute({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) => _passenger.previewRoute(pickup: pickup, dropoff: dropoff, stops: stops);

  @override
  Future<BookingQuoteEntity> quoteBooking({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) => _passenger.quoteBooking(pickup: pickup, dropoff: dropoff, stops: stops);

  @override
  Future<List<PaymentMethodEntity>> paymentMethods() =>
      _passenger.paymentMethods();

  @override
  Future<PaymentConfigEntity> paymentConfig() => _passenger.paymentConfig();

  @override
  Future<CreateBookingResult> createBooking({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    required String idempotencyKey,
  }) => _passenger.createBooking(
    serviceCategoryId: serviceCategoryId,
    pickup: pickup,
    dropoff: dropoff,
    stops: stops,
    paymentMethodCode: paymentMethodCode,
    idempotencyKey: idempotencyKey,
  );

  @override
  Future<BookingPaymentEntity> bookingPayment(String bookingId) =>
      _passenger.bookingPayment(bookingId);

  @override
  Future<BookingEntity?> activeBooking() => _passenger.activeBooking();

  @override
  Future<BookingEntity?> bookingById(String bookingId) =>
      _passenger.bookingById(bookingId);

  @override
  Future<BookingEntity?> cancelBooking(
    String bookingId, {
    String? reason,
    String? idempotencyKey,
  }) => _passenger.cancelBooking(
    bookingId,
    reason: reason,
    idempotencyKey: idempotencyKey,
  );

  @override
  Future<RecordingConsentResult> submitRecordingConsent({
    required String bookingId,
    required bool consent,
  }) => _passenger.submitRecordingConsent(
    bookingId: bookingId,
    consent: consent,
  );
}
