import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rydu_user/app/router/app_router.dart';
import 'package:rydu_user/app/router/route_names.dart';
import 'package:rydu_user/core/location/location_service.dart';
import 'package:rydu_user/core/network/passenger_api_error_mapper.dart';
import 'package:rydu_user/core/network/passenger_socket_service.dart';
import 'package:rydu_user/core/storage/secure_storage_service.dart';
import 'package:rydu_user/features/activity/presentation/screens/activity_screen.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/fare_estimate_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/pickup_spot_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_booking_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_destination_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_option_entity.dart';
import 'package:rydu_user/features/ride_booking/domain/entities/ride_planning_entities.dart';
import 'package:rydu_user/features/ride_booking/domain/repositories/ride_booking_repository.dart';
import 'package:rydu_user/features/ride_booking/presentation/providers/ride_booking_provider.dart';
import 'package:rydu_user/features/ride_history/domain/entities/pagination_meta.dart';
import 'package:rydu_user/features/ride_history/domain/entities/ride_history_page.dart';
import 'package:rydu_user/features/ride_history/domain/repositories/ride_history_repository.dart';
import 'package:rydu_user/features/ride_history/domain/ride_history_filter.dart';
import 'package:rydu_user/features/ride_history/presentation/providers/ride_history_provider.dart';
import 'package:rydu_user/features/ride_history/presentation/screens/ride_details_screen.dart';
import 'package:rydu_user/features/ride_history/presentation/screens/ride_history_screen.dart';
import 'package:rydu_user/features/ride_history/presentation/widgets/ride_history_body.dart';
import 'package:rydu_user/features/ride_history/presentation/widgets/ride_history_card.dart';

class _FakeHistoryRepo implements RideHistoryRepository {
  List<BookingEntity> all = [];
  Object? error;
  BookingEntity? detail;
  final calls = <({int page, int limit, RideHistoryFilter filter})>[];

  @override
  Future<RideHistoryPage> listRides({
    required int page,
    required int limit,
    required RideHistoryFilter filter,
  }) async {
    calls.add((page: page, limit: limit, filter: filter));
    if (error != null) throw error!;
    var source = all;
    if (filter == RideHistoryFilter.completed) {
      source = all.where((e) => e.status == 'completed').toList();
    } else if (filter == RideHistoryFilter.cancelled) {
      source = all
          .where(
            (e) =>
                e.status == 'cancelled' ||
                e.status == 'canceled' ||
                e.status == 'no_drivers',
          )
          .toList();
    }
    final start = (page - 1) * limit;
    final slice = start >= source.length
        ? <BookingEntity>[]
        : source.skip(start).take(limit).toList();
    final totalPages = source.isEmpty
        ? 1
        : ((source.length + limit - 1) / limit).ceil();
    return RideHistoryPage(
      items: slice,
      pagination: PaginationMeta(
        page: page,
        limit: limit,
        total: source.length,
        totalPages: totalPages,
      ),
    );
  }

  @override
  Future<BookingEntity?> getRide(String id) async {
    if (error != null) throw error!;
    if (detail != null && detail!.id == id) return detail;
    for (final item in all) {
      if (item.id == id) return item;
    }
    return detail;
  }
}

class _FakeRideRepo implements RideBookingRepository {
  BookingEntity? active;

  @override
  String getDefaultPickupLocation() => '';

  @override
  Future<List<RideDestinationEntity>> getSuggestedLocations() async => [];

  @override
  Future<RideDestinationEntity?> findDestinationById(String id) async => null;

  @override
  Future<List<RideOptionEntity>> getRideOptions() async => [];

  @override
  Future<RideOptionEntity?> findRideOptionById(String id) async => null;

  @override
  Future<List<PickupSpotEntity>> getPickupSpots() async => [];

  @override
  String pickupSpotLabel(int index) => '';

  @override
  Future<FareEstimateEntity> estimateFare({
    required String rideType,
    required String optionId,
  }) async => throw UnimplementedError();

  @override
  Future<void> confirmPickup({required RideBookingEntity booking}) async {}

  @override
  Future<String> createRideRequest({
    required RideBookingEntity booking,
  }) async => 'id';

  @override
  Future<String> createRideDraft() async => 'draft';

  @override
  Future<void> confirmRide({required String rideDraftId}) async {}

  @override
  Future<PlaceEntity?> reverseGeocode({
    required double lat,
    required double lng,
  }) async => null;

  @override
  Future<List<PlacePredictionEntity>> autocomplete({
    required String input,
    double? lat,
    double? lng,
    String? city,
    String? country,
    String? sessionToken,
    dynamic cancelToken,
  }) async => [];

  @override
  Future<PlaceEntity?> placeDetails({
    required String placeId,
    String? sessionToken,
  }) async => null;

  @override
  Future<List<PlacePredictionEntity>> placeSuggestions({
    double? lat,
    double? lng,
  }) async => [];

  @override
  Future<List<PickupSpotEntity>> fetchPickupSpots({
    required double lat,
    required double lng,
    String? address,
  }) async => [];

  @override
  Future<List<NearbyDriverEntity>> nearbyDrivers({
    required double lat,
    required double lng,
    required String serviceCategoryId,
    double? radiusKm,
  }) async => [];

  @override
  Future<RoutePreviewEntity> previewRoute({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) async => throw UnimplementedError();

  @override
  Future<BookingQuoteEntity> quoteBooking({
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
  }) async => throw UnimplementedError();

  @override
  Future<List<PaymentMethodEntity>> paymentMethods() async => [];

  @override
  Future<PaymentConfigEntity> paymentConfig() async =>
      const PaymentConfigEntity(stripeEnabled: false, cardEnabled: false);

  @override
  Future<CreateBookingResult> createBooking({
    required String serviceCategoryId,
    required LatLngWaypoint pickup,
    required LatLngWaypoint dropoff,
    List<LatLngWaypoint> stops = const [],
    required String paymentMethodCode,
    required String idempotencyKey,
  }) async => throw UnimplementedError();

  @override
  Future<BookingPaymentEntity> bookingPayment(String bookingId) async =>
      throw UnimplementedError();

  @override
  Future<BookingEntity?> activeBooking() async => active;

  @override
  Future<BookingEntity?> bookingById(String bookingId) async => active;

  @override
  Future<BookingEntity?> cancelBooking(
    String bookingId, {
    String? reason,
    String? idempotencyKey,
  }) async => BookingEntity(id: bookingId, status: 'cancelled');

  @override
  Future<RecordingConsentResult> submitRecordingConsent({
    required String bookingId,
    required bool consent,
  }) async => RecordingConsentResult(consent: consent);
}

BookingEntity _booking({
  required String id,
  required String status,
  String pickup = 'Dhanmondi',
  String dropoff = 'Mirpur',
  String? reason,
  DateTime? at,
}) {
  return BookingEntity(
    id: id,
    status: status,
    pickupAddress: pickup,
    dropoffAddress: dropoff,
    serviceName: 'CNG',
    finalFare: 120,
    currency: 'BDT',
    createdAt: at ?? DateTime(2026, 8, 10, 11, 30),
    completedAt: status == 'completed' ? at ?? DateTime(2026, 8, 10, 11, 30) : null,
    cancelledAt: status == 'cancelled' || status == 'canceled'
        ? at ?? DateTime(2026, 8, 10, 11, 30)
        : null,
    cancellationReason: reason,
  );
}

RideBookingState _activeState() {
  return const RideBookingState(
    bookingId: 'active-1',
    bookingStatus: 'accepted',
    phase: RidePlanningPhase.driverAccepted,
    pickupLocation: 'Banani',
    selectedVehicle: RideOptionEntity(
      id: 'cng',
      name: 'CNG',
      category: 'recommended',
      time: '5 min',
      description: '',
      price: 'BDT 90.00',
    ),
    dropoffPlace: PlaceEntity(
      placeId: 'p',
      label: 'Gulshan',
      address: 'Dhaka',
      latitude: 23.79,
      longitude: 90.41,
    ),
  );
}

ProviderContainer _container({
  required _FakeHistoryRepo history,
  _FakeRideRepo? ride,
  GoRouter? router,
}) {
  final rideRepo = ride ?? _FakeRideRepo();
  final goRouter =
      router ??
      GoRouter(
        initialLocation: RouteNames.home,
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.findingDriver,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.driverFound,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.rideSelection,
            builder: (_, _) => const SizedBox(),
          ),
          GoRoute(
            path: RouteNames.activity,
            builder: (_, _) => const ActivityScreen(),
          ),
          GoRoute(
            path: RouteNames.rideHistory,
            builder: (_, _) => const RideHistoryScreen(),
          ),
          GoRoute(
            path: RouteNames.rideDetails,
            builder: (context, state) => RideDetailsScreen(
              rideId: state.uri.queryParameters['rideId'],
            ),
          ),
        ],
      );
  return ProviderContainer(
    overrides: [
      rideHistoryRepositoryProvider.overrideWithValue(history),
      rideBookingRepositoryProvider.overrideWithValue(rideRepo),
      locationServiceProvider.overrideWithValue(LocationService()),
      passengerSocketServiceProvider.overrideWithValue(
        PassengerSocketService(SecureStorageService()),
      ),
      goRouterProvider.overrideWithValue(goRouter),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RideHistoryController', () {
    test('page 1 load', () async {
      final history = _FakeHistoryRepo()
        ..all = [_booking(id: 'c1', status: 'completed')];
      final container = _container(history: history);
      addTearDown(container.dispose);
      await container.read(rideHistoryControllerProvider.notifier).loadInitial();
      final state = container.read(rideHistoryControllerProvider);
      expect(history.calls.single.page, 1);
      expect(history.calls.single.limit, 20);
      expect(state.items, hasLength(1));
      expect(state.page, 1);
      expect(state.hasFetched, isTrue);
    });

    test('page 2 appends and ignores duplicate ids', () async {
      final history = _FakeHistoryRepo()
        ..all = [
          for (var i = 0; i < 25; i++)
            _booking(id: 'id-$i', status: 'completed'),
        ];
      final container = _container(history: history);
      addTearDown(container.dispose);
      final c = container.read(rideHistoryControllerProvider.notifier);
      await c.loadInitial();
      expect(container.read(rideHistoryControllerProvider).items, hasLength(20));
      await c.loadMore();
      final state = container.read(rideHistoryControllerProvider);
      expect(state.page, 2);
      expect(state.items, hasLength(25));
      expect(state.items.map((e) => e.id).toSet(), hasLength(25));
      await c.loadMore();
      expect(container.read(rideHistoryControllerProvider).items, hasLength(25));
    });

    test('totalPages stops pagination', () async {
      final history = _FakeHistoryRepo()
        ..all = [_booking(id: 'c1', status: 'completed')];
      final container = _container(history: history);
      addTearDown(container.dispose);
      final c = container.read(rideHistoryControllerProvider.notifier);
      await c.loadInitial();
      expect(container.read(rideHistoryControllerProvider).canLoadMore, isFalse);
      await c.loadMore();
      expect(history.calls, hasLength(1));
    });

    test('filter change resets page', () async {
      final history = _FakeHistoryRepo()
        ..all = [
          _booking(id: 'c1', status: 'completed'),
          _booking(id: 'x1', status: 'cancelled'),
          _booking(id: 'n1', status: 'no_drivers'),
        ];
      final container = _container(history: history);
      addTearDown(container.dispose);
      final c = container.read(rideHistoryControllerProvider.notifier);
      await c.loadInitial();
      await c.setFilter(RideHistoryFilter.cancelled);
      final state = container.read(rideHistoryControllerProvider);
      expect(state.selectedFilter, RideHistoryFilter.cancelled);
      expect(state.page, 1);
      expect(history.calls.last.filter, RideHistoryFilter.cancelled);
      expect(state.items.map((e) => e.status).toSet(), {'cancelled', 'no_drivers'});
    });

    test('cancelled filter can contain Cancelled and Expired', () async {
      final history = _FakeHistoryRepo()
        ..all = [
          _booking(id: 'x1', status: 'cancelled'),
          _booking(id: 'n1', status: 'no_drivers'),
        ];
      final container = _container(history: history);
      addTearDown(container.dispose);
      final c = container.read(rideHistoryControllerProvider.notifier);
      await c.setFilter(RideHistoryFilter.cancelled);
      final items = container.read(rideHistoryControllerProvider).items;
      expect(items.any((e) => e.status == 'cancelled'), isTrue);
      expect(items.any((e) => e.status == 'no_drivers'), isTrue);
    });

    test('pull-to-refresh resets page', () async {
      final history = _FakeHistoryRepo()
        ..all = [
          for (var i = 0; i < 25; i++)
            _booking(id: 'id-$i', status: 'completed'),
        ];
      final container = _container(history: history);
      addTearDown(container.dispose);
      final c = container.read(rideHistoryControllerProvider.notifier);
      await c.loadInitial();
      await c.loadMore();
      expect(container.read(rideHistoryControllerProvider).page, 2);
      await c.refresh();
      expect(container.read(rideHistoryControllerProvider).page, 1);
      expect(container.read(rideHistoryControllerProvider).items, hasLength(20));
    });

    test('terminal state triggers history refresh', () async {
      final history = _FakeHistoryRepo()
        ..all = [_booking(id: 'c1', status: 'completed')];
      final container = _container(history: history);
      addTearDown(container.dispose);
      final rideC = container.read(rideBookingControllerProvider.notifier);
      rideC.debugSeedState(_activeState());
      final historyC = container.read(rideHistoryControllerProvider.notifier);
      await historyC.loadInitial();
      final before = history.calls.length;
      rideC.debugSeedState(
        const RideBookingState(phase: RidePlanningPhase.completed),
      );
      await Future<void>.delayed(Duration.zero);
      expect(history.calls.length, greaterThan(before));
    });

    test('history load failure keeps active card', () async {
      final history = _FakeHistoryRepo()
        ..error = const PassengerApiException('Network error. Check your connection and try again.');
      final container = _container(history: history);
      addTearDown(container.dispose);
      final rideC = container.read(rideBookingControllerProvider.notifier);
      rideC.debugSeedState(_activeState());
      await container.read(rideHistoryControllerProvider.notifier).loadInitial();
      final ride = container.read(rideBookingControllerProvider);
      final state = container.read(rideHistoryControllerProvider);
      expect(ride.hasActiveBooking, isTrue);
      expect(state.errorMessage, isNotNull);
      expect(state.items, isEmpty);
    });

    test('empty previous rides', () async {
      final history = _FakeHistoryRepo();
      final container = _container(history: history);
      addTearDown(container.dispose);
      await container.read(rideHistoryControllerProvider.notifier).loadInitial();
      final state = container.read(rideHistoryControllerProvider);
      expect(state.items, isEmpty);
      expect(state.hasFetched, isTrue);
    });

    test('active booking id is excluded from previous list', () {
      const state = RideHistoryState(
        items: [
          BookingEntity(id: 'active-1', status: 'completed'),
          BookingEntity(id: 'old-1', status: 'completed'),
        ],
      );
      final previous = state.previousRides(activeBookingId: 'active-1');
      expect(previous.map((e) => e.id), ['old-1']);
    });

    test('Activity and Account History share the same controller/list', () async {
      final history = _FakeHistoryRepo()
        ..all = [_booking(id: 'c1', status: 'completed')];
      final container = _container(history: history);
      addTearDown(container.dispose);
      await container.read(rideHistoryControllerProvider.notifier).loadInitial();
      expect(
        container.read(rideHistoryControllerProvider).items.single.id,
        'c1',
      );
      expect(
        container.read(rideHistoryControllerProvider.notifier),
        same(container.read(rideHistoryControllerProvider.notifier)),
      );
    });
  });

  group('Ride history widgets', () {
    testWidgets('active ride appears first and is not duplicated', (
      tester,
    ) async {
      final history = _FakeHistoryRepo()
        ..all = [
          _booking(id: 'active-1', status: 'completed'),
          _booking(id: 'old-1', status: 'completed', pickup: 'Uttara'),
        ];
      final container = _container(history: history);
      addTearDown(container.dispose);
      container
          .read(rideBookingControllerProvider.notifier)
          .debugSeedState(_activeState());
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: RideHistoryBody(title: 'Activity'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Active Ride'), findsOneWidget);
      expect(find.text('Previous rides'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Active Ride')).dy,
        lessThan(tester.getTopLeft(find.text('Previous rides')).dy),
      );
      expect(find.text('View ride'), findsOneWidget);
      expect(find.textContaining('Uttara'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('no active ride hides Active Ride section', (tester) async {
      final history = _FakeHistoryRepo()
        ..all = [_booking(id: 'old-1', status: 'completed')];
      final container = _container(history: history);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: RideHistoryBody(title: 'Activity'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Active Ride'), findsNothing);
      expect(find.text('Previous rides'), findsOneWidget);
    });

    testWidgets('no_drivers card shows Expired not Completed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RideHistoryCard(
              booking: _booking(id: 'n1', status: 'no_drivers'),
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('Completed'), findsNothing);
      expect(find.text('Cancelled'), findsNothing);
    });

    testWidgets('completed and cancelled chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              RideHistoryCard(
                booking: _booking(id: 'c1', status: 'completed'),
                onTap: () {},
              ),
              RideHistoryCard(
                booking: _booking(id: 'x1', status: 'cancelled'),
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('historical ride opens read-only detail with reason', (
      tester,
    ) async {
      final history = _FakeHistoryRepo()
        ..all = [
          _booking(
            id: 'x1',
            status: 'cancelled',
            reason: 'Wait time was too long',
          ),
        ]
        ..detail = _booking(
          id: 'x1',
          status: 'cancelled',
          reason: 'Wait time was too long',
        );
      final container = _container(history: history);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: RideDetailsScreen(rideId: 'x1')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ride details'), findsOneWidget);
      expect(find.text('Wait time was too long'), findsOneWidget);
      expect(find.text('Cancelled'), findsWidgets);
      expect(find.text('Cancel ride'), findsNothing);
      expect(find.text('Chat'), findsNothing);
      expect(find.textContaining('Calling'), findsNothing);
    });

    testWidgets('empty previous rides copy', (tester) async {
      final history = _FakeHistoryRepo();
      final container = _container(history: history);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: RideHistoryBody(title: 'Activity'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("You don't have any recent activity"), findsOneWidget);
    });

    testWidgets('active ride tap resumes live ride', (tester) async {
      final history = _FakeHistoryRepo();
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const RideHistoryBody(title: 'Activity'),
          ),
          GoRoute(
            path: RouteNames.findingDriver,
            builder: (_, _) => const Text('finding-driver'),
          ),
          GoRoute(
            path: RouteNames.driverFound,
            builder: (_, _) => const Text('driver-found'),
          ),
        ],
      );
      final container = _container(history: history, router: router);
      addTearDown(container.dispose);
      container
          .read(rideBookingControllerProvider.notifier)
          .debugSeedState(_activeState());
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('View ride'));
      await tester.pumpAndSettle();
      expect(find.text('driver-found'), findsOneWidget);
    });
  });
}
