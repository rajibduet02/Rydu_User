/// Backend booking / quote billing classification.
///
/// The booking-create response is authoritative over any earlier quote value.
enum BookingBillingMode {
  unknown,
  meteredPostTrip,
  quotedPrepay,
}

extension BookingBillingModeParsing on BookingBillingMode {
  static BookingBillingMode fromRaw(String? raw) {
    if (raw == null) return BookingBillingMode.unknown;
    final value = raw.trim().toLowerCase().replaceAll('-', '_');
    return switch (value) {
      'metered_post_trip' ||
      'meteredposttrip' ||
      'soft_meter' ||
      'softmeter' => BookingBillingMode.meteredPostTrip,
      'quoted_prepay' ||
      'quotedprepay' ||
      'quoted' ||
      'prepay' ||
      'fixed' => BookingBillingMode.quotedPrepay,
      _ => BookingBillingMode.unknown,
    };
  }

  String? get wireValue => switch (this) {
    BookingBillingMode.meteredPostTrip => 'metered_post_trip',
    BookingBillingMode.quotedPrepay => 'quoted_prepay',
    BookingBillingMode.unknown => null,
  };
}
