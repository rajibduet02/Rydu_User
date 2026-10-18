import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../domain/entities/ride_planning_entities.dart';
import '../../domain/service_area/service_area_cache.dart';
import '../../domain/service_area/service_area_models.dart';
import '../../domain/service_area/service_area_rules.dart';
import '../datasources/service_area_remote_datasource.dart';

abstract interface class ServiceAreaRepository {
  Future<ServiceAreaDecision> decide({
    required PlaceEntity pickup,
    PlaceEntity? dropoff,
    List<PlaceEntity> stops = const [],
  });

  ServiceAreaConfig? get activeConfig;
}

class ServiceAreaRepositoryImpl implements ServiceAreaRepository {
  ServiceAreaRepositoryImpl(
    this._remote, {
    ServiceAreaCache? cache,
  }) : _cache = cache ?? ServiceAreaCache();

  final ServiceAreaRemoteDatasource _remote;
  final ServiceAreaCache _cache;

  @override
  ServiceAreaConfig? get activeConfig => _cache.active;

  @override
  Future<ServiceAreaDecision> decide({
    required PlaceEntity pickup,
    PlaceEntity? dropoff,
    List<PlaceEntity> stops = const [],
  }) async {
    if (!pickup.hasCoordinates) {
      _cache.hideActiveBoundary();
      return const ServiceAreaDecision.cleared();
    }

    final query = ServiceAreaQuery.forPickup(pickup);
    try {
      final config = await _load(query);
      return ServiceAreaRules.evaluate(
        config: config,
        pickup: pickup,
        dropoff: dropoff,
        stops: stops,
      );
    } on PassengerApiException catch (error) {
      _cache.hideActiveBoundary();
      if (error.code == 'SERVICE_AREA_UNAVAILABLE') {
        return const ServiceAreaDecision.unavailable();
      }
      return const ServiceAreaDecision(
        config: null,
        allowsQuoteOrBooking: true,
        serviceUnavailable: false,
      );
    } catch (_) {
      _cache.hideActiveBoundary();
      return const ServiceAreaDecision(
        config: null,
        allowsQuoteOrBooking: true,
        serviceUnavailable: false,
      );
    }
  }

  Future<ServiceAreaConfig> _load(ServiceAreaQuery query) {
    final cached = _cache.lookup(query.cacheKey);
    if (cached != null) {
      return Future<ServiceAreaConfig>.value(_cache.activate(cached));
    }
    final existing = _cache.inFlight[query.cacheKey];
    if (existing != null) {
      return existing.then(_cache.activate);
    }

    _cache.hideActiveBoundary();
    final future = _remote.fetch(query).then((config) {
      _cache.storeQuery(query.cacheKey, config);
      return _cache.activate(config);
    });
    _cache.inFlight[query.cacheKey] = future;
    return future.whenComplete(() => _cache.inFlight.remove(query.cacheKey));
  }
}
