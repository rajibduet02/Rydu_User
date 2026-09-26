/// Presentation-only catalog for current passenger ride categories.
///
/// Codes are backend service codes (not UUIDs). Quote responses remain
/// authoritative for [serviceCategoryId] and fare.
class PassengerServiceCategoryPresentation {
  const PassengerServiceCategoryPresentation({
    required this.code,
    required this.displayName,
    required this.iconKey,
    required this.capacity,
  });

  /// Backend service code, e.g. `ECONOMY`. Never a category UUID.
  final String code;
  final String displayName;
  final String iconKey;
  final int capacity;
}

/// Current bookable ride categories shown on Home / Services entry points.
///
/// Not loaded from GET /passenger/services (that client is not wired yet).
/// Order matches the product catalog; quote order still comes from the API.
abstract final class PassengerServiceCategories {
  static const economy = PassengerServiceCategoryPresentation(
    code: 'ECONOMY',
    displayName: 'Economy Sedan',
    iconKey: 'economy',
    capacity: 3,
  );

  static const executive = PassengerServiceCategoryPresentation(
    code: 'EXECUTIVE',
    displayName: 'Executive Sedan',
    iconKey: 'executive',
    capacity: 3,
  );

  static const suv = PassengerServiceCategoryPresentation(
    code: 'SUV',
    displayName: 'SUV',
    iconKey: 'suv',
    capacity: 6,
  );

  static const van = PassengerServiceCategoryPresentation(
    code: 'VAN',
    displayName: 'Passenger Van',
    iconKey: 'van',
    capacity: 8,
  );

  static const minivan = PassengerServiceCategoryPresentation(
    code: 'MINIVAN',
    displayName: 'Mini-Van',
    iconKey: 'minivan',
    capacity: 5,
  );

  static const ada = PassengerServiceCategoryPresentation(
    code: 'ADA',
    displayName: 'ADA Accessible',
    iconKey: 'ada',
    capacity: 4,
  );

  static const List<PassengerServiceCategoryPresentation> current = [
    economy,
    executive,
    suv,
    van,
    minivan,
    ada,
  ];

  static bool isCurrentRideCode(String value) {
    final upper = value.trim().toUpperCase();
    for (final item in current) {
      if (item.code == upper) return true;
    }
    return false;
  }
}
