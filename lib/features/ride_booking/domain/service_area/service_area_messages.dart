import 'service_area_models.dart';

abstract final class ServiceAreaMessages {
  static const outOfService = serviceAreaOutOfBoundsMessage;
  static const unavailable = serviceAreaUnavailableMessage;

  static List<String> failedPointsFromDetails(Map<String, dynamic>? details) {
    return normalizeFailedPoints(details?['failedPoints']);
  }

  static List<String> normalizeFailedPoints(dynamic raw) {
    if (raw is! List) return const [];
    final points = <String>[];
    for (final item in raw) {
      final value = _pointToken(item);
      if (value == null || points.contains(value)) continue;
      points.add(value);
    }
    return points;
  }

  static String outOfServiceMessage(List<String> failedPoints) {
    if (failedPoints.isEmpty) return outOfService;
    final labels = failedPoints.map(labelFor).join(', ');
    return '$outOfService Check $labels.';
  }

  static String labelFor(String token) {
    return switch (token) {
      'pickup' => 'pickup',
      'dropoff' => 'drop-off',
      'stop' => 'stop',
      _ => token,
    };
  }

  static String? _pointToken(dynamic item) {
    if (item is String) {
      final value = item.trim().toLowerCase();
      return value.isEmpty ? null : value;
    }
    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final raw = map['point'] ?? map['role'] ?? map['type'] ?? map['code'];
      if (raw == null) return null;
      final value = raw.toString().trim().toLowerCase();
      return value.isEmpty ? null : value;
    }
    return null;
  }
}
