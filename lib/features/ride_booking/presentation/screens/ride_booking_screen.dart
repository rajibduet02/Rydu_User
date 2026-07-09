import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../models/ride_booking_route_args.dart';
import '../providers/ride_booking_provider.dart';
import '../theme/ride_booking_tokens.dart';
import '../widgets/location_input_card.dart';
import '../widgets/ride_booking_action_tile.dart';
import '../widgets/suggested_location_tile.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key, required this.routeArgs});

  final RideBookingRouteArgs routeArgs;

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  late final FocusNode _destinationFocusNode;
  bool _seededFromRoute = false;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: '35 Road No. 2');
    _destinationController = TextEditingController();
    _destinationFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(rideBookingControllerProvider);
    final c = ref.read(rideBookingControllerProvider.notifier);

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
        _pickupController.text = next.pickupLocation;
        _destinationController.text = next.destinationQuery;
      });
    }

    return Scaffold(
      backgroundColor: RideBookingTokens.background,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LocationInputCard(
                      pickupController: _pickupController,
                      destinationController: _destinationController,
                      destinationFocusNode: _destinationFocusNode,
                      onPickupChanged: c.updatePickupLocation,
                      onDestinationChanged: c.updateDestinationQuery,
                      onDestinationTap: _destinationFocusNode.requestFocus,
                      onPlusTap: () {
                        c.addStop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Multi-stop rides are not available yet.',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    if (s.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        s.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    for (final loc in s.suggestedLocations) ...[
                      SuggestedLocationTile(
                        location: loc,
                        onTap: () {
                          c.selectDestination(loc.id);
                          final updated = ref.read(
                            rideBookingControllerProvider,
                          );
                          final d = updated.selectedDestination;
                          if (d == null) return;
                          _destinationController.text =
                              updated.destinationQuery;
                          c.continueToRideSelection();
                        },
                      ),
                    ],
                    const SizedBox(height: 8),
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
            ),
          ],
        ),
      ),
    );
  }
}
