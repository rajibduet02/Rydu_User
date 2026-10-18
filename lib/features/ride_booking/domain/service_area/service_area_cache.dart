import 'service_area_models.dart';

/// Remembers service-area payloads by query and by market version.
/// The active config is always the market of the latest pickup query.
class ServiceAreaCache {
  final Map<String, ServiceAreaConfig> _byQuery = {};
  final Map<String, ServiceAreaConfig> _byMarket = {};
  final Map<String, Future<ServiceAreaConfig>> inFlight = {};

  ServiceAreaConfig? active;

  ServiceAreaConfig? lookup(String queryKey) => _byQuery[queryKey];

  void hideActiveBoundary() {
    active = null;
  }

  ServiceAreaConfig activate(ServiceAreaConfig incoming) {
    final market = incoming.normalizedMarket;
    final cached = _byMarket[market];
    final ServiceAreaConfig chosen;
    if (cached != null && cached.maxVersion > incoming.maxVersion) {
      chosen = cached;
    } else {
      _byMarket[market] = incoming;
      chosen = incoming;
    }
    active = chosen;
    return chosen;
  }

  void storeQuery(String queryKey, ServiceAreaConfig config) {
    _byQuery[queryKey] = config;
  }

  void clear() {
    _byQuery.clear();
    _byMarket.clear();
    inFlight.clear();
    active = null;
  }
}
