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
}
