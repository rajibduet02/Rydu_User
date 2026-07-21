import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/location/location_service.dart';
import '../models/ride_booking_route_args.dart';
import '../models/suggested_location.dart';
import '../providers/ride_booking_provider.dart';
import '../theme/ride_booking_tokens.dart';
import '../widgets/location_input_card.dart';
import '../widgets/ride_booking_action_tile.dart';
import '../widgets/suggested_location_tile.dart';
import '../../domain/entities/ride_planning_entities.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key, required this.routeArgs});

  final RideBookingRouteArgs routeArgs;

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  late final FocusNode _pickupFocusNode;
  late final FocusNode _destinationFocusNode;
  bool _seededFromRoute = false;
  bool _syncingControllers = false;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController();
    _destinationController = TextEditingController();
    _pickupFocusNode = FocusNode();
    _destinationFocusNode = FocusNode();
    _pickupFocusNode.addListener(_onPickupFocusChanged);
    _destinationFocusNode.addListener(_onDestinationFocusChanged);
  }

  @override
  void dispose() {
    _pickupFocusNode.removeListener(_onPickupFocusChanged);
    _destinationFocusNode.removeListener(_onDestinationFocusChanged);
    _pickupController.dispose();
    _destinationController.dispose();
    _pickupFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  void _onPickupFocusChanged() {
    if (_pickupFocusNode.hasFocus) {
      ref
          .read(rideBookingControllerProvider.notifier)
          .setActiveSearchField(ActiveSearchField.pickup);
    } else {
      final s = ref.read(rideBookingControllerProvider);
      if (!s.hasResolvedPickup) {
        ref.read(rideBookingControllerProvider.notifier).cancelPickupEditing();
        final restored = ref.read(rideBookingControllerProvider).pickupLocation;
        _syncPickupProgrammatically(restored);
      }
    }
  }

  void _onDestinationFocusChanged() {
    if (_destinationFocusNode.hasFocus) {
      ref
          .read(rideBookingControllerProvider.notifier)
          .setActiveSearchField(ActiveSearchField.destination);
    }
  }

  void _syncControllerText(TextEditingController controller, String next) {
    if (_syncingControllers) return;
    if (controller.text == next) return;
    _syncingControllers = true;
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    _syncingControllers = false;
  }

  void _syncPickupProgrammatically(String next) {
    final notifier = ref.read(rideBookingControllerProvider.notifier);
    notifier.suppressPickupTextInvalidation = true;
    _syncControllerText(_pickupController, next);
    notifier.suppressPickupTextInvalidation = false;
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(rideBookingControllerProvider);
    final c = ref.read(rideBookingControllerProvider.notifier);

    ref.listen(rideBookingControllerProvider, (prev, next) {
      // Sync pickup whenever GPS / place-details resolve. Do not key off
      // placeId — current-location pickups often have an empty placeId.
      final pickupChanged =
          prev?.pickupLocation != next.pickupLocation ||
          prev?.isPickupResolved != next.isPickupResolved ||
          prev?.pickupPlace?.latitude != next.pickupPlace?.latitude ||
          prev?.pickupPlace?.longitude != next.pickupPlace?.longitude;

      if (pickupChanged) {
        final userTypingPickup =
            _pickupFocusNode.hasFocus &&
            next.activeSearchField == ActiveSearchField.pickup &&
            !next.hasResolvedPickup;
        if (!userTypingPickup) {
          _syncPickupProgrammatically(next.pickupLocation);
        }
      }

      if (next.hasResolvedDestination &&
          prev?.destinationQuery != next.destinationQuery &&
          !_destinationFocusNode.hasFocus) {
        _syncControllerText(_destinationController, next.destinationQuery);
      }
    });

    if (!_seededFromRoute) {
      _seededFromRoute = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        c.initializeSelectedType(
          widget.routeArgs.selectedType,
          rentalHours: widget.routeArgs.rentalHours,
          leaveOption: widget.routeArgs.leaveOption,
          rentalVehicle: widget.routeArgs.rentalVehicle,
          rentalPrice: widget.routeArgs.price,
          paymentMethod: widget.routeArgs.paymentMethod,
        );
        final next = ref.read(rideBookingControllerProvider);
        _syncPickupProgrammatically(next.pickupLocation);
        _syncControllerText(_destinationController, next.destinationQuery);
      });
    }

    final activeQuery = s.activeSearchField == ActiveSearchField.pickup
        ? s.pickupLocation.trim()
        : s.destinationQuery.trim();
    final showSearchPanel =
        s.activeSearchField != ActiveSearchField.none &&
        activeQuery.length >= 2;

    final isPickupLoading =
        s.phase == RidePlanningPhase.locating ||
        s.phase == RidePlanningPhase.reverseGeocoding ||
        (s.isLoading && s.pickupLocation.isEmpty);

    return Scaffold(
      backgroundColor: RideBookingTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.home);
                        }
                      },
                      customBorder: const CircleBorder(),
                      child: Ink(
                        width: RideBookingTokens.headerButtonSize,
                        height: RideBookingTokens.headerButtonSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: RideBookingTokens.headerButtonFill,
                          border: Border.all(color: RideBookingTokens.border),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: RideBookingTokens.titleWhite,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Plan your ride',
                      style: TextStyle(
                        color: RideBookingTokens.titleWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LocationInputCard(
                pickupController: _pickupController,
                destinationController: _destinationController,
                pickupFocusNode: _pickupFocusNode,
                destinationFocusNode: _destinationFocusNode,
                isPickupLoading: isPickupLoading,
                onPickupChanged: (value) {
                  if (_syncingControllers) return;
                  c.updatePickupLocation(value);
                },
                onDestinationChanged: (value) {
                  if (_syncingControllers) return;
                  c.updateDestinationQuery(value);
                },
                onPickupTap: () {
                  _pickupFocusNode.requestFocus();
                  c.setActiveSearchField(ActiveSearchField.pickup);
                },
                onDestinationTap: () {
                  _destinationFocusNode.requestFocus();
                  c.setActiveSearchField(ActiveSearchField.destination);
                },
                onPlusTap: () {
                  c.addStop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Multi-stop rides are not available yet.'),
                    ),
                  );
                },
              ),
            ),
            if (s.phase == RidePlanningPhase.permissionDenied) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  s.errorMessage ?? 'Location permission required.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
              if (s.permissionStatus ==
                  AppLocationPermissionStatus.deniedForever)
                TextButton(
                  onPressed: c.openAppSettingsForLocation,
                  child: const Text('Open Settings'),
                )
              else
                TextButton(
                  onPressed: () =>
                      c.bootstrapCurrentLocation(userInitiated: true),
                  child: const Text('Retry location'),
                ),
            ],
            if (s.isResolvingPlace || s.isLoadingRoute) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(
                  color: RideBookingTokens.accent,
                ),
              ),
            ],
            if (s.errorMessage != null &&
                s.phase != RidePlanningPhase.permissionDenied) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final query =
                            s.activeSearchField == ActiveSearchField.pickup
                            ? s.pickupLocation
                            : s.destinationQuery;
                        if (s.activeSearchField == ActiveSearchField.pickup) {
                          c.updatePickupLocation(query);
                        } else {
                          c.updateDestinationQuery(query);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: showSearchPanel
                  ? _PredictionList(
                      isLoading: s.isSearchingPlaces,
                      predictions: s.predictions,
                      onSelect: c.selectPrediction,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      children: [
                        RideBookingActionTile(
                          icon: Icons.my_location_rounded,
                          label: 'Use current location',
                          onTap: () async {
                            await c.useCurrentLocation();
                            if (!mounted) return;
                            final next = ref.read(
                              rideBookingControllerProvider,
                            );
                            _syncPickupProgrammatically(next.pickupLocation);
                          },
                        ),
                        for (final loc in s.suggestedLocations)
                          SuggestedLocationTile(
                            location: loc,
                            onTap: () => c.selectDestination(loc.id),
                          ),
                        RideBookingActionTile(
                          icon: Icons.public_outlined,
                          label: 'Search in a different city',
                          onTap: c.searchDifferentCity,
                        ),
                        RideBookingActionTile(
                          icon: Icons.location_on_outlined,
                          label: 'Set location on map',
                          onTap: c.setLocationOnMap,
                        ),
                        RideBookingActionTile(
                          icon: Icons.star_border_rounded,
                          label: 'Saved places',
                          onTap: c.openSavedPlaces,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionList extends StatelessWidget {
  const _PredictionList({
    required this.isLoading,
    required this.predictions,
    required this.onSelect,
  });

  final bool isLoading;
  final List<PlacePredictionEntity> predictions;
  final ValueChanged<PlacePredictionEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    if (isLoading && predictions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: RideBookingTokens.accent,
            ),
          ),
        ),
      );
    }

    if (!isLoading && predictions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Text(
          'No locations found',
          style: TextStyle(color: RideBookingTokens.muted, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: predictions.length + (isLoading ? 1 : 0),
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: RideBookingTokens.border),
      itemBuilder: (context, index) {
        if (isLoading && index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final predictionIndex = isLoading ? index - 1 : index;
        final prediction = predictions[predictionIndex];
        return SuggestedLocationTile(
          location: SuggestedLocation(
            id: prediction.placeId,
            name: prediction.primaryText,
            address: prediction.secondaryText,
            distance: '',
            placeId: prediction.placeId,
            latitude: prediction.latitude,
            longitude: prediction.longitude,
          ),
          onTap: () => onSelect(prediction),
        );
      },
    );
  }
}
