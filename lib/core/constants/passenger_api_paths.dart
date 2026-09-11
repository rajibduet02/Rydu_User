import '../constants/api_constants.dart';

/// Passenger API path helpers (relative to [ApiConstants.baseUrl]).
abstract final class PassengerApiPaths {
  static String get _p => ApiConstants.passengerPathPrefix;

  static String get reverseGeocode => '$_p/places/reverse-geocode';
  static String get autocomplete => '$_p/places/autocomplete';
  static String get placeDetails => '$_p/places/details';
  static String get placeSuggestions => '$_p/places/suggestions';
  static String get places => '$_p/places';
  static String placeById(String placeId) => '$_p/places/$placeId';
  static String get pickupSpots => '$_p/pickup-spots';
  static String get routePreview => '$_p/routes/preview';
  static String get bookingQuote => '$_p/bookings/quote';
  static String get services => '$_p/services';
  static String get paymentMethods => '$_p/payment-methods';
  static String get paymentsConfig => '/api/v1/config/payments';
  static String get nearbyDrivers => '$_p/drivers/nearby';
  static String get bookings => '$_p/bookings';
  static String get activeBooking => '$_p/bookings/active';
  static String bookingById(String bookingId) => '$_p/bookings/$bookingId';
  static String bookingPayment(String bookingId) =>
      '$_p/bookings/$bookingId/payment';
  static String cancelBooking(String bookingId) =>
      '$_p/bookings/$bookingId/cancel';
  static String recordingConsent(String bookingId) =>
      '$_p/bookings/$bookingId/recording-consent';

  static String get profile => '$_p/profile';
  static String get profileAvatar => '$_p/profile/avatar';
  static String get profileDeactivate => '$_p/profile/deactivate';

  static String get pushToken => '$_p/push-token';
}
