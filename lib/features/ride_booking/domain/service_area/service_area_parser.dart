import 'service_area_geometry.dart';
import 'service_area_models.dart';

abstract final class ServiceAreaParser {
  static ServiceAreaConfig? parseEnvelope(dynamic raw) {
    if (raw is! Map) return null;
    final root = Map<String, dynamic>.from(raw);
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    return parseData(data);
  }

  static ServiceAreaConfig? parseData(Map<String, dynamic> data) {
    final market = data['marketCode']?.toString().trim() ?? '';
    if (market.isEmpty) return null;
    final areasRaw = data['areas'];
    final areas = <ServiceAreaRegion>[];
    if (areasRaw is List) {
      for (final item in areasRaw) {
        final region = _region(item);
        if (region != null) areas.add(region);
      }
    }
    return ServiceAreaConfig(
      marketCode: market,
      enforcementEnabled: data['enforcementEnabled'] == true,
      areas: areas,
    );
  }

  static ServiceAreaRegion? _region(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final code = map['code']?.toString().trim() ?? '';
    final name = map['name']?.toString().trim() ?? code;
    if (code.isEmpty && name.isEmpty) return null;
    final version = map['version'] is num ? (map['version'] as num).toInt() : 0;
    final geometry = map['geometry'];
    return ServiceAreaRegion(
      code: code.isEmpty ? name : code,
      name: name.isEmpty ? code : name,
      version: version,
      policy: map['policy']?.toString() ?? '',
      polygons: ServiceAreaGeometry.polygonsFromGeometry(geometry),
    );
  }
}
