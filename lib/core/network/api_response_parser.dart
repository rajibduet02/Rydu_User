/// Helpers for parsing common API envelope shapes.
abstract final class ApiResponseParser {
  /// Returns nested `data` map when present, otherwise the root map.
  static Map<String, dynamic> unwrapData(dynamic raw) {
    if (raw is! Map) {
      throw const FormatException('Expected JSON object response.');
    }
    final root = Map<String, dynamic>.from(raw);
    final data = root['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return root;
  }

  /// Returns a list payload from envelopes such as `{ "data": [ ... ] }`
  /// or `{ "data": { "predictions": [ ... ] } }`.
  static List<dynamic> unwrapList(
    dynamic raw, {
    List<String> nestedKeys = const [
      'predictions',
      'suggestions',
      'places',
      'items',
      'results',
      'spots',
      'pickupSpots',
      'paymentMethods',
      'methods',
      'quotes',
      'drivers',
      'bookings',
    ],
  }) {
    if (raw is List) return List<dynamic>.from(raw);
    if (raw is! Map) return const [];

    final root = Map<String, dynamic>.from(raw);
    final data = root['data'];

    if (data is List) return List<dynamic>.from(data);

    if (data is Map) {
      final nested = Map<String, dynamic>.from(data);
      for (final key in nestedKeys) {
        final value = nested[key];
        if (value is List) return List<dynamic>.from(value);
      }
    }

    for (final key in nestedKeys) {
      final value = root[key];
      if (value is List) return List<dynamic>.from(value);
    }

    return const [];
  }
}
