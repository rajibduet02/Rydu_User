import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rydu_user/core/network/passenger_api_error_mapper.dart';
import 'package:rydu_user/features/ride_booking/data/datasources/service_area_remote_datasource.dart';
import 'package:rydu_user/features/ride_booking/data/repositories/service_area_repository_impl.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_destination_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/domain/service_area/service_area_cache.dart';
import 'package:rydu_user/features/ride_booking/domain/service_area/service_area_geometry.dart';
import 'package:rydu_user/features/ride_booking/domain/service_area/service_area_messages.dart';
import 'package:rydu_user/features/ride_booking/domain/service_area/service_area_models.dart';
import 'package:rydu_user/features/ride_booking/domain/service_area/service_area_parser.dart';
import 'package:rydu_user/features/ride_booking/domain/service_area/service_area_rules.dart';
import 'package:rydu_user/features/ride_booking/presentation/models/ride_vehicle_option.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';
import 'package:rydu_user/features/ride_booking/presentation/service_area/service_area_polygons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Coronado service area', () {
    test('1. US active boundary displays as a polygon', () {
      final config = _usConfig();
      expect(config.showsRestrictionPolygon, isTrue);
      final polygons = serviceAreaPolygons(config);
      expect(polygons, hasLength(1));
      final polygon = polygons.single;
      expect(polygon.points.first.latitude, 32.6);
      expect(polygon.points.first.longitude, -117.2);
      expect(polygon.polygonId.value, 'service-area-0');
    });

    test('2. BD market has no polygon restriction', () {
      final config = _bdConfig(enforcementEnabled: true);
      expect(config.showsRestrictionPolygon, isFalse);
      expect(serviceAreaPolygons(config), isEmpty);
      final decision = ServiceAreaRules.evaluate(
        config: config,
        pickup: _place(23.81, 90.41),
        dropoff: _place(23.75, 90.39),
      );
      expect(decision.allowsQuoteOrBooking, isTrue);
      expect(decision.showsRestrictionPolygon, isFalse);
    });

    test('3. US enforcement disabled does not block booking', () {
      final config = _usConfig(enforcementEnabled: false);
      expect(config.showsRestrictionPolygon, isFalse);
      final decision = ServiceAreaRules.evaluate(
        config: config,
        pickup: _place(23.81, 90.41),
        dropoff: _place(23.75, 90.39),
      );
      expect(decision.allowsQuoteOrBooking, isTrue);
      expect(decision.message, isNull);
    });

    test('4. pickup outside boundary displays the correct error', () {
      final decision = ServiceAreaRules.evaluate(
        config: _usConfig(),
        pickup: _place(23.81, 90.41),
        dropoff: _inside(),
      );
      expect(decision.allowsQuoteOrBooking, isFalse);
      expect(decision.failedPoints, ['pickup']);
      expect(
        decision.message,
        contains(ServiceAreaMessages.outOfService),
      );
      expect(decision.message, contains('pickup'));
    });

    test('5. drop-off outside boundary displays the correct error', () {
      final decision = ServiceAreaRules.evaluate(
        config: _usConfig(),
        pickup: _inside(),
        dropoff: _place(23.81, 90.41),
      );
      expect(decision.failedPoints, ['dropoff']);
      expect(decision.message, contains('drop-off'));
      expect(decision.message, contains(ServiceAreaMessages.outOfService));
    });

    test('6. intermediate stop outside boundary displays the correct error', () {
      final decision = ServiceAreaRules.evaluate(
        config: _usConfig(),
        pickup: _inside(),
        dropoff: _inside(latitude: 32.66, longitude: -117.16),
        stops: [_place(23.81, 90.41)],
      );
      expect(decision.failedPoints, ['stop']);
      expect(decision.allowsQuoteOrBooking, isFalse);
      expect(decision.message, contains('stop'));
      expect(decision.message, contains(ServiceAreaMessages.outOfService));
    });

    test('7. SERVICE_AREA_UNAVAILABLE prevents booking', () async {
      final container = ProviderContainer(
        overrides: [
          serviceAreaRepositoryProvider.overrideWithValue(
            _FixedAreaRepository(const ServiceAreaDecision.unavailable()),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(rideBookingControllerProvider.notifier);
      controller.debugSeedState(_readyToBook());
      await controller.confirmBooking();
      final state = container.read(rideBookingControllerProvider);
      expect(state.isCreatingBooking, isFalse);
      expect(state.phase, RidePlanningPhase.quoteLoaded);
      expect(state.bookingId, isNull);
      expect(state.errorMessage, ServiceAreaMessages.unavailable);
      expect(state.isSearchingForDriver, isFalse);
    });

    test('8. GeoJSON coordinate conversion keeps longitude first', () {
      final point = ServiceAreaGeometry.pointFromGeoJson([-117.18, 32.68]);
      expect(point, isNotNull);
      expect(point!.latitude, 32.68);
      expect(point.longitude, -117.18);
      final reversed = ServiceAreaGeometry.pointFromGeoJson([32.68, -117.18]);
      expect(reversed, isNull);
    });

    test('9. Polygon and MultiPolygon parsing', () {
      final polygon = ServiceAreaParser.parseData({
        'marketCode': 'US',
        'enforcementEnabled': true,
        'areas': [
          {
            'code': 'coronado',
            'name': 'Coronado',
            'version': 1,
            'policy': 'pickup_and_dropoff',
            'geometry': {
              'type': 'Polygon',
              'coordinates': [_squareRing()],
            },
          },
        ],
      });
      expect(polygon!.drawablePolygons, hasLength(1));

      final multi = ServiceAreaParser.parseData({
        'marketCode': 'US',
        'enforcementEnabled': true,
        'areas': [
          {
            'code': 'coronado',
            'name': 'Coronado',
            'version': 2,
            'policy': 'pickup_and_dropoff',
            'geometry': {
              'type': 'MultiPolygon',
              'coordinates': [
                [_squareRing()],
                [_squareRing(lat: 1, lng: 1)],
              ],
            },
          },
        ],
      });
      expect(multi!.drawablePolygons, hasLength(2));
      expect(
        ServiceAreaGeometry.contains(multi, 1.05, 1.05),
        isTrue,
      );
      expect(ServiceAreaGeometry.contains(multi, 10, 10), isFalse);
    });

    test('10. holes are excluded from the service area', () {
      final config = ServiceAreaParser.parseData({
        'marketCode': 'US',
        'enforcementEnabled': true,
        'areas': [
          {
            'code': 'coronado',
            'name': 'Coronado',
            'version': 1,
            'policy': 'pickup_and_dropoff',
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                _squareRing(),
                [
                  [-117.18, 32.62],
                  [-117.12, 32.62],
                  [-117.12, 32.68],
                  [-117.18, 32.68],
                  [-117.18, 32.62],
                ],
              ],
            },
          },
        ],
      })!;
      expect(ServiceAreaGeometry.contains(config, 32.61, -117.19), isTrue);
      expect(ServiceAreaGeometry.contains(config, 32.65, -117.15), isFalse);
      final polygon = serviceAreaPolygons(config).single;
      expect(polygon.holes, hasLength(1));
      expect(polygon.holes.single.first.latitude, 32.62);
      expect(polygon.holes.single.first.longitude, -117.18);
    });

    test('11. changing from US to BD clears the previous boundary', () async {
      final remote = _ScriptedRemote([_usConfig(), _bdConfig()]);
      final repo = ServiceAreaRepositoryImpl(remote);
      final us = await repo.decide(
        pickup: _inside(),
        dropoff: _inside(latitude: 32.66, longitude: -117.16),
      );
      expect(us.showsRestrictionPolygon, isTrue);
      final bd = await repo.decide(
        pickup: _place(23.81, 90.41, id: 'bd-pickup'),
        dropoff: _place(23.75, 90.39, id: 'bd-drop'),
      );
      expect(bd.config!.normalizedMarket, 'BD');
      expect(bd.showsRestrictionPolygon, isFalse);
      expect(repo.activeConfig!.showsRestrictionPolygon, isFalse);
      expect(serviceAreaPolygons(repo.activeConfig), isEmpty);
    });

    test('12. passenger physically in BD can book a valid US ride', () {
      const deviceInDhaka = GeoPointEntity(latitude: 23.8103, longitude: 90.4125);
      final pickup = _inside();
      final query = ServiceAreaQuery.forPickup(pickup);
      final decision = ServiceAreaRules.evaluate(
        config: _usConfig(),
        pickup: pickup,
        dropoff: _inside(latitude: 32.66, longitude: -117.16),
      );
      expect(query.usesDeviceLocation, isFalse);
      expect(query.latitude, isNot(deviceInDhaka.latitude));
      expect(query.longitude, isNot(deviceInDhaka.longitude));
      expect(decision.allowsQuoteOrBooking, isTrue);
      expect(decision.failedPoints, isEmpty);
    });

    test('13. existing booking phases and live tracking stay independent', () {
      expect(
        ridePhaseFromBookingStatus('accepted'),
        RidePlanningPhase.driverAccepted,
      );
      expect(
        ridePhaseFromBookingStatus('en_route'),
        RidePlanningPhase.driverEnRoute,
      );
      expect(
        ridePhaseFromBookingStatus('in_progress'),
        RidePlanningPhase.rideInProgress,
      );
      expect(const ServiceAreaDecision.idle().allowsQuoteOrBooking, isTrue);
      expect(ActiveRideSocketStatus.connected.name, 'connected');
    });

    test('cached market version is replaced only by a newer version', () {
      final cache = ServiceAreaCache();
      final first = cache.activate(_usConfig(version: 1));
      expect(first.maxVersion, 1);
      final newer = cache.activate(_usConfig(version: 3));
      expect(newer.maxVersion, 3);
      final older = cache.activate(_usConfig(version: 2));
      expect(older.maxVersion, 3);
      expect(cache.active!.maxVersion, 3);
    });

    test('repeated pickup query does not refetch', () async {
      final remote = _ScriptedRemote([_usConfig(), _usConfig()]);
      final repo = ServiceAreaRepositoryImpl(remote);
      await repo.decide(pickup: _inside(), dropoff: _inside());
      await repo.decide(
        pickup: _inside(),
        dropoff: _inside(latitude: 32.66, longitude: -117.16),
      );
      expect(remote.calls, 1);
    });

    test('quote and create errors use the service-area copy', () {
      final outside = PassengerApiErrorMapper.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/bookings/quote'),
          response: Response(
            requestOptions: RequestOptions(path: '/bookings/quote'),
            statusCode: 400,
            data: {
              'success': false,
              'error': {
                'code': 'OUT_OF_SERVICE_AREA',
                'message': 'outside',
                'details': {
                  'failedPoints': ['pickup', 'stop'],
                },
              },
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(outside.code, 'OUT_OF_SERVICE_AREA');
      expect(outside.message, contains(ServiceAreaMessages.outOfService));
      expect(outside.message, contains('pickup'));
      expect(outside.message, contains('stop'));

      final unavailable = PassengerApiErrorMapper.fromEnvelope({
        'success': false,
        'error': {
          'code': 'SERVICE_AREA_UNAVAILABLE',
          'message': 'down',
        },
      });
      expect(unavailable!.message, ServiceAreaMessages.unavailable);
    });
  });
}

PlaceEntity _place(double latitude, double longitude, {String id = 'p'}) {
  return PlaceEntity(
    placeId: id,
    label: 'Place',
    address: 'Address',
    latitude: latitude,
    longitude: longitude,
  );
}

PlaceEntity _inside({double latitude = 32.65, double longitude = -117.15}) {
  return _place(latitude, longitude, id: 'inside');
}

List<List<double>> _squareRing({double lat = 32.6, double lng = -117.2}) {
  return [
    [lng, lat],
    [lng + 0.1, lat],
    [lng + 0.1, lat + 0.1],
    [lng, lat + 0.1],
    [lng, lat],
  ];
}

ServiceAreaConfig _usConfig({bool enforcementEnabled = true, int version = 1}) {
  return ServiceAreaParser.parseData({
    'marketCode': 'US',
    'enforcementEnabled': enforcementEnabled,
    'areas': [
      {
        'code': 'coronado',
        'name': 'Coronado',
        'version': version,
        'policy': 'pickup_and_dropoff',
        'geometry': {
          'type': 'Polygon',
          'coordinates': [_squareRing()],
        },
      },
    ],
  })!;
}

ServiceAreaConfig _bdConfig({bool enforcementEnabled = false}) {
  return ServiceAreaParser.parseData({
    'marketCode': 'BD',
    'enforcementEnabled': enforcementEnabled,
    'areas': const [],
  })!;
}

class _ScriptedRemote implements ServiceAreaRemoteDatasource {
  _ScriptedRemote(this._responses);

  final List<ServiceAreaConfig> _responses;
  int calls = 0;

  @override
  Future<ServiceAreaConfig> fetch(ServiceAreaQuery query) async {
    final config = _responses[calls];
    calls += 1;
    return config;
  }
}

class _FixedAreaRepository implements ServiceAreaRepository {
  _FixedAreaRepository(this.decision);

  final ServiceAreaDecision decision;

  @override
  ServiceAreaConfig? get activeConfig => decision.config;

  @override
  Future<ServiceAreaDecision> decide({
    required PlaceEntity pickup,
    PlaceEntity? dropoff,
    List<PlaceEntity> stops = const [],
  }) async {
    return decision;
  }
}

RideBookingState _readyToBook() {
  return RideBookingState(
    pickupPlace: _inside(),
    dropoffPlace: _inside(latitude: 32.66, longitude: -117.16),
    selectedDestination: const RideDestinationEntity(
      id: 'd1',
      name: 'Coronado',
      address: 'Coronado',
      distance: '',
    ),
    selectedVehicle: const RideVehicleOption(
      id: 'svc1',
      name: 'Ride',
      category: 'recommended',
      time: '',
      description: '',
      price: 'USD 12.00',
    ),
    selectedVehicleId: 'svc1',
    estimatedFare: 'USD 12.00',
    isPickupResolved: true,
    pickupSource: PickupSource.manualSelection,
    phase: RidePlanningPhase.quoteLoaded,
  );
}
