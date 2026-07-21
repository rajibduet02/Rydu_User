import 'suggested_location.dart';
import 'ride_vehicle_option.dart';

abstract final class RideFlowExtra {
  static String stringFrom(Object? raw, [String fallback = '']) {
    if (raw == null) return fallback;
    return raw.toString();
  }

  static SuggestedLocation? destinationFrom(Object? raw) {
    if (raw is SuggestedLocation) return raw;
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final name = m['name'] as String?;
    if (name == null || name.isEmpty) return null;
    return SuggestedLocation(
      id: m['id'] as String? ?? name,
      name: name,
      address: m['address'] as String? ?? '',
      distance: m['distance'] as String? ?? '',
      latitude: (m['latitude'] as num?)?.toDouble(),
      longitude: (m['longitude'] as num?)?.toDouble(),
      placeId: m['placeId'] as String?,
    );
  }

  static Map<String, dynamic> destinationMap(SuggestedLocation? d) {
    if (d == null) return {};
    return {
      'id': d.id,
      'name': d.name,
      'address': d.address,
      'distance': d.distance,
      'latitude': d.latitude,
      'longitude': d.longitude,
      'placeId': d.placeId,
    };
  }

  static Map<String, dynamic> parseMap(Object? extra) {
    if (extra is Map<String, dynamic>) return extra;
    if (extra is Map) return Map<String, dynamic>.from(extra);
    return {};
  }

  static Map<String, dynamic> buildSelectionExtra({
    required String selectedType,
    required String pickupLocation,
    SuggestedLocation? destination,
    Map<String, dynamic>? pickupPlace,
    Map<String, dynamic>? dropoffPlace,
    Map<String, dynamic>? routePreview,
  }) => {
    'selectedType': selectedType,
    'pickupLocation': pickupLocation,
    'destination': destinationMap(destination),
    'pickupPlace': ?pickupPlace,
    'dropoffPlace': ?dropoffPlace,
    'routePreview': ?routePreview,
  };

  static Map<String, dynamic> buildConfirmPickupExtra({
    required String selectedType,
    required RideVehicleOption selectedVehicle,
    required String pickupLocation,
    SuggestedLocation? destination,
    required String estimatedFare,
    required String paymentMethod,
  }) => {
    'selectedType': selectedType,
    'selectedVehicle': selectedVehicle.toExtra(),
    'pickupLocation': pickupLocation,
    'destination': destinationMap(destination),
    'estimatedFare': estimatedFare,
    'paymentMethod': paymentMethod,
  };

  static Map<String, dynamic> buildDriverFoundExtra({
    required String selectedType,
    required RideVehicleOption selectedVehicle,
    required String pickupLocation,
    SuggestedLocation? destination,
    required String estimatedFare,
    required String paymentMethod,
    String? pickupSpotName,
    String? bookingId,
  }) => {
    ...buildConfirmPickupExtra(
      selectedType: selectedType,
      selectedVehicle: selectedVehicle,
      pickupLocation: pickupLocation,
      destination: destination,
      estimatedFare: estimatedFare,
      paymentMethod: paymentMethod,
    ),
    'pickupSpotName': pickupSpotName,
    'bookingId': ?bookingId,
  };
}
