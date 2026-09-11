import '../../domain/entities/ride_planning_entities.dart';

/// POST /bookings body. Fare/amount is calculated by backend — never send it.
abstract final class BookingCreateRequest {
  static Map<String, dynamic> body({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    String schedulingType = 'instant',
  }) {
    return {
      'serviceCategoryId': serviceCategoryId,
      'pickup': pickup.toJson(includeSpotLabel: true),
      'dropoff': dropoff.toJson(),
      'stops': stops.map((s) => s.toJson()).toList(),
      'paymentMethodCode': paymentMethodCode,
      'schedulingType': schedulingType,
    };
  }
}
