import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../ride_booking/presentation/models/ride_flow_extra.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../../../ride_booking/presentation/widgets/active_ride_map.dart';
import '../theme/finding_driver_tokens.dart';
import '../widgets/finding_driver_animation.dart';
import '../widgets/ride_requested_card.dart';

class FindingDriverScreen extends ConsumerStatefulWidget {
  const FindingDriverScreen({super.key});

  @override
  ConsumerState<FindingDriverScreen> createState() =>
      _FindingDriverScreenState();
}

class _FindingDriverScreenState extends ConsumerState<FindingDriverScreen> {
  bool _initialized = false;
  Timer? _elapsedTicker;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _elapsedTicker?.cancel();
    super.dispose();
  }

  void _syncElapsedTicker(RideBookingState state) {
    final started = state.searchStartedAt;
    final searching = state.isSearchingForDriver;
    if (!searching || started == null) {
      _elapsedTicker?.cancel();
      _elapsedTicker = null;
      return;
    }
    void tick() {
      if (!mounted) return;
      setState(() => _elapsed = DateTime.now().difference(started));
    }

    tick();
    _elapsedTicker ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => tick(),
    );
  }

  void _handlePhaseNavigation(RideBookingState state) {
    final c = ref.read(rideBookingControllerProvider.notifier);
    if (state.isAssignedRidePhase) {
      if (c.hasNavigatedForPhase(state.phase)) return;
      c.markPhaseNavigated(state.phase);
      final vehicle = state.selectedVehicle;
      if (vehicle == null) return;
      context.pushReplacement(
        RouteNames.driverFound,
        extra: RideFlowExtra.buildDriverFoundExtra(
          selectedType: state.selectedRideType,
          selectedVehicle: vehicle,
          pickupLocation: state.pickupLocation,
          destination: state.selectedDestination,
          estimatedFare: state.estimatedFare ?? vehicle.price,
          paymentMethod: state.paymentMethod,
          pickupSpotName: state.pickupSpotLabel,
          bookingId: state.bookingId,
        ),
      );
      return;
    }

    if (state.phase == RidePlanningPhase.cancelled) {
      if (c.hasNavigatedForPhase(state.phase)) return;
      c.markPhaseNavigated(state.phase);
      context.go(RouteNames.home);
    }
  }

  Future<void> _cancel() async {
    final ok = await ref
        .read(rideBookingControllerProvider.notifier)
        .cancelActiveBooking();
    if (!mounted) return;
    if (ok) {
      context.go(RouteNames.home);
    }
  }

  Future<void> _onBackMinimize() async {
    final state = ref.read(rideBookingControllerProvider);
    if (state.isCancelling) return;

    final isExpired =
        state.phase == RidePlanningPhase.expired ||
        state.phase == RidePlanningPhase.noDrivers;
    if (isExpired) {
      ref
          .read(rideBookingControllerProvider.notifier)
          .dismissExpiredBookingToHome();
      return;
    }

    final choice = await showDialog<_MinimizeChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FindingDriverTokens.card,
        title: const Text(
          'Leave this screen?',
          style: TextStyle(color: FindingDriverTokens.white),
        ),
        content: const Text(
          'Your ride request will continue while you browse the app.',
          style: TextStyle(color: FindingDriverTokens.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(_MinimizeChoice.cancelRide),
            child: const Text('Cancel ride'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(_MinimizeChoice.keepSearching),
            style: FilledButton.styleFrom(
              backgroundColor: FindingDriverTokens.accent,
            ),
            child: const Text('Keep searching'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (choice == _MinimizeChoice.cancelRide) {
      await _cancel();
      return;
    }
    // Keep searching (default for back/minimize) or dialog dismissed via Keep.
    if (choice == null || choice == _MinimizeChoice.keepSearching) {
      if (choice == null) return; // dialog dismissed — stay on screen
      ref.read(rideBookingControllerProvider.notifier).minimizeActiveRide();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your ride request will continue while you browse the app.',
          ),
        ),
      );
    }
  }

  String _elapsedLabel() {
    final total = _elapsed.inSeconds;
    final m = total ~/ 60;
    final s = total % 60;
    if (m <= 0) return 'Searching · ${s}s';
    return 'Searching · ${m}m ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideBookingControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.055).clamp(22.0, 24.0);
    final subtitleSize = (w * 0.038).clamp(14.0, 15.0);

    ref.listen<RideBookingState>(rideBookingControllerProvider, (prev, next) {
      if (!mounted) return;
      _syncElapsedTicker(next);
      if (prev?.phase != next.phase) {
        _handlePhaseNavigation(next);
      }
    });

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = ref.read(rideBookingControllerProvider);
        _syncElapsedTicker(current);
        _handlePhaseNavigation(current);
      });
    }

    final isExpired =
        state.phase == RidePlanningPhase.expired ||
        state.phase == RidePlanningPhase.noDrivers;
    final reconnecting =
        state.socketStatus == ActiveRideSocketStatus.reconnecting ||
        state.socketStatus == ActiveRideSocketStatus.disconnected;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onBackMinimize();
      },
      child: Scaffold(
        backgroundColor: FindingDriverTokens.background,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: (w * 0.48).clamp(180.0, 220.0),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ActiveRideMap(
                        showDriver: false,
                        bottomPadding: 32,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.paddingOf(context).top + 8,
                      left: 12,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: state.isCancelling
                              ? null
                              : _onBackMinimize,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: FindingDriverTokens.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 24),
                      child: Column(
                        children: [
                          Text(
                            isExpired
                                ? 'No drivers are available right now.'
                                : 'Ride requested',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FindingDriverTokens.white,
                              fontWeight: FontWeight.w700,
                              fontSize: titleSize,
                            ),
                          ),
                          SizedBox(height: (w * 0.015).clamp(6.0, 8.0)),
                          Text(
                            isExpired
                                ? 'Try again, change service, or return home'
                                : reconnecting
                                ? 'Reconnecting… keeping your booking'
                                : state.isSearchingForDriver
                                ? _elapsedLabel()
                                : 'Finding drivers nearby',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FindingDriverTokens.muted,
                              fontSize: subtitleSize,
                            ),
                          ),
                          if (!isExpired) ...[
                            SizedBox(height: (w * 0.06).clamp(24.0, 32.0)),
                            const FindingDriverAnimation(),
                          ],
                          SizedBox(height: (w * 0.06).clamp(24.0, 32.0)),
                          RideRequestedCard(
                            pickupSpotName: state.pickupSpotLabel.isNotEmpty
                                ? state.pickupSpotLabel
                                : (state.pickupLocation.isNotEmpty
                                      ? state.pickupLocation
                                      : 'Pickup'),
                            fareLabel: state.estimatedFare,
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (isExpired) ...[
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => ref
                                    .read(
                                      rideBookingControllerProvider.notifier,
                                    )
                                    .retryAfterExpired(),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Try again'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => ref
                                    .read(
                                      rideBookingControllerProvider.notifier,
                                    )
                                    .changeServiceAfterExpired(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: FindingDriverTokens.white,
                                  side: const BorderSide(
                                    color: FindingDriverTokens.border,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Change service'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => ref
                                  .read(rideBookingControllerProvider.notifier)
                                  .dismissExpiredBookingToHome(),
                              child: const Text(
                                'Return Home',
                                style: TextStyle(
                                  color: FindingDriverTokens.muted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ] else
                            TextButton(
                              onPressed:
                                  state.isCancelling || !state.canCancelBooking
                                  ? null
                                  : _cancel,
                              child: state.isCancelling
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Cancel ride',
                                      style: TextStyle(
                                        color: FindingDriverTokens.muted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MinimizeChoice { keepSearching, cancelRide }
