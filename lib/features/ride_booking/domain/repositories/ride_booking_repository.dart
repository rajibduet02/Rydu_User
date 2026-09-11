import '../entities/fare_estimate_entity.dart';
import '../entities/pickup_spot_entity.dart';
import '../entities/ride_booking_entity.dart';
import '../entities/ride_destination_entity.dart';
import '../entities/ride_option_entity.dart';
import '../entities/ride_planning_entities.dart';

abstract interface class RideBookingRepository {
  String getDefaultPickupLocation();

  Future<List<RideDestinationEntity>> getSuggestedLocations();

  Future<RideDestinationEntity?> findDestinationById(String id);

  Future<List<RideOptionEntity>> getRideOptions();

  Future<RideOptionEntity?> findRideOptionById(String id);

  Future<List<PickupSpotEntity>> getPickupSpots();

  String pickupSpotLabel(int index);

  Future<FareEstimateEntity> estimateFare({
    required String rideType,
    required String optionId,
  });

  Future<void> confirmPickup({required RideBookingEntity booking});

  Future<String> createRideRequest({required RideBookingEntity booking});

  Future<String> createRideDraft();

  Future<void> confirmRide({required String rideDraftId});

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
    dynamic cancelToken,
  });

  Future<PlaceEntity?> placeDetails({
    required String placeId,
    String? sessionToken,
  });

  Future<List<PlacePredictionEntity>> placeSuggestions({
    double? lat,
    double? lng,
  });

  Future<List<PickupSpotEntity>> fetchPickupSpots({
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
