import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../ride_booking/presentation/models/ride_flow_extra.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../../../ride_booking/presentation/theme/ride_booking_tokens.dart';
import '../../../ride_booking/presentation/widgets/active_ride_map.dart';
import '../providers/driver_found_provider.dart';
import '../widgets/driver_info_card.dart';
import '../widgets/recording_consent_overlay.dart';
import '../widgets/trip_details_card.dart';

class DriverFoundScreen extends ConsumerStatefulWidget {
  const DriverFoundScreen({super.key});

  @override
  ConsumerState<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends ConsumerState<DriverFoundScreen> {
  bool _initialized = false;
  bool _showCancelSheet = false;
  bool _showCancelConfirm = false;
  String? _cancelReason;

  static const _cancelReasons = [
    ('🚗', 'Driver not getting closer'),
    ('🪖', 'No helmet provided'),
    ('⏰', 'Wait time was too long'),
    ('🚫', 'Could not find driver'),
    ('❌', 'Driver asked me to cancel'),
    ('📝', 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    final ride = ref.watch(rideBookingControllerProvider);
    final state = ref.watch(driverFoundControllerProvider);
    final c = ref.read(driverFoundControllerProvider.notifier);

    ref.listen<RideBookingState>(rideBookingControllerProvider, (prev, next) {
      if (!mounted) return;
      c.syncFromRideBooking(next);
      final booking = ref.read(rideBookingControllerProvider.notifier);
      if (next.phase == RidePlanningPhase.cancelled ||
          next.phase == RidePlanningPhase.completed) {
        if (booking.hasNavigatedForPhase(next.phase)) return;
        booking.markPhaseNavigated(next.phase);
        context.go(RouteNames.home);
      } else if (next.phase == RidePlanningPhase.expired ||
          next.phase == RidePlanningPhase.noDrivers) {
        if (booking.hasNavigatedForPhase(next.phase)) return;
        booking.markPhaseNavigated(next.phase);
        context.pushReplacement(RouteNames.findingDriver);
      }
    });

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        c.initializeFromExtra(
          RideFlowExtra.parseMap(GoRouterState.of(context).extra),
        );
      });
    }

    final title = state.eta.isNotEmpty
        ? 'Pickup in ${state.eta}'
        : (state.tripStatus.isNotEmpty ? state.tripStatus : 'Driver assigned');

    return Scaffold(
      backgroundColor: RideBookingTokens.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: ActiveRideMap(showDriver: true),
                      ),
                      if (ride.socketStatus ==
                              ActiveRideSocketStatus.reconnecting ||
                          ride.socketStatus ==
                              ActiveRideSocketStatus.disconnected)
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 12,
                          left: 16,
                          right: 72,
                          child: Material(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                'Reconnecting… ride status preserved',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 12,
                        right: 16,
                        child: _CircleIcon(
                          icon: Icons.share_outlined,
                          onTap: () {
                            c.shareTripStatus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Trip status sharing coming soon',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: RideBookingTokens.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border(
                      top: BorderSide(color: RideBookingTokens.border),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: c.toggleTripDetails,
                          child: Container(
                            width: 48,
                            height: 6,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: RideBookingTokens.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: RideBookingTokens.titleWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🪖', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Remember to wear a helmet throughout your trip',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: RideBookingTokens.muted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (ride.recordingConsentStatusLabel != null) ...[
                          RecordingConsentStatusBanner(
                            label: ride.recordingConsentStatusLabel!,
                          ),
                          const SizedBox(height: 12),
                        ],
                        _StatusCard(
                          pickupSpotName: state.pickupSpotName.isNotEmpty
                              ? state.pickupSpotName
                              : state.pickupLocation,
                          tripStatus: state.tripStatus.isNotEmpty
                              ? state.tripStatus
                              : 'Active',
                          onMore: c.toggleTripDetails,
                        ),
                        const SizedBox(height: 12),
                        DriverInfoCard(
                          plateNumber: state.plateNumber.isNotEmpty
                              ? state.plateNumber
                              : '—',
                          driverName: state.driverName.isNotEmpty
                              ? state.driverName
                              : 'Driver assigned',
                          onMessage: c.messageDriver,
                          onCall: () {
                            c.callDriver();
                            final phone = ride.assignedDriver?.phone;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  phone != null && phone.isNotEmpty
                                      ? 'Calling driver $phone…'
                                      : 'Driver phone unavailable',
                                ),
                              ),
                            );
                          },
                        ),
                        if (state.showTripDetails) ...[
                          const SizedBox(height: 12),
                          TripDetailsCard(
                            pickupSpotName: state.pickupSpotName,
                            destination: state.destination,
                            rideId: state.rideId,
                            paymentMethod: state.paymentMethod,
                            estimatedFare: state.estimatedFare,
                            onShareTrip: () {
                              c.shareTripStatus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Share trip status coming soon',
                                  ),
                                ),
                              );
                            },
                            onCancelRide: () {
                              setState(() => _showCancelSheet = true);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_showCancelSheet)
              _CancelReasonSheet(
                reasons: _cancelReasons,
                onClose: () => setState(() => _showCancelSheet = false),
                onSelect: (reason) {
                  setState(() {
                    _cancelReason = reason;
                    _showCancelSheet = false;
                    _showCancelConfirm = true;
                  });
                },
              ),
            if (_showCancelConfirm)
              _CancelConfirmDialog(
                driverName: state.driverName.isNotEmpty
                    ? state.driverName
                    : 'your driver',
                onClose: () => setState(() => _showCancelConfirm = false),
                onYesCancel: () async {
                  final ok = await c.cancelRide(
                    reason: _cancelReason ?? 'Passenger cancelled',
                  );
                  if (!context.mounted) return;
                  if (ok) {
                    context.go(RouteNames.home);
                  } else {
                    setState(() => _showCancelConfirm = false);
                  }
                },
                onFindAnother: () => setState(() => _showCancelConfirm = false),
                onNo: () => setState(() => _showCancelConfirm = false),
              ),
            if (ride.shouldShowRecordingConsentPrompt &&
                !_showCancelSheet &&
                !_showCancelConfirm)
              RecordingConsentOverlay(
                isSubmitting:
                    ride.recordingConsentStatus ==
                    RecordingConsentStatus.submitting,
                isFailed:
                    ride.recordingConsentStatus ==
                    RecordingConsentStatus.failed,
                errorMessage: ride.recordingConsentError,
                onAllow: () {
                  ref
                      .read(rideBookingControllerProvider.notifier)
                      .submitRecordingConsent(true);
                },
                onDecline: () {
                  ref
                      .read(rideBookingControllerProvider.notifier)
                      .submitRecordingConsent(false);
                },
                onRetry: () {
                  ref
                      .read(rideBookingControllerProvider.notifier)
                      .retryRecordingConsent();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.pickupSpotName,
    required this.tripStatus,
    required this.onMore,
  });

  final String pickupSpotName;
  final String tripStatus;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RideBookingTokens.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RideBookingTokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: RideBookingTokens.accent,
            ),
            alignment: Alignment.center,
            child: const Text('📍', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meet at the pickup spot for',
                  style: TextStyle(
                    color: RideBookingTokens.muted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pickupSpotName,
                  style: const TextStyle(
                    color: RideBookingTokens.titleWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '● $tripStatus',
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _CircleIcon(icon: Icons.more_horiz_rounded, onTap: onMore),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RideBookingTokens.plusFill,
          ),
          child: Icon(icon, color: RideBookingTokens.titleWhite, size: 20),
        ),
      ),
    );
  }
}

class _CancelReasonSheet extends StatelessWidget {
  const _CancelReasonSheet({
    required this.reasons,
    required this.onClose,
    required this.onSelect,
  });

  final List<(String, String)> reasons;
  final VoidCallback onClose;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(color: Colors.black.withValues(alpha: 0.6)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: RideBookingTokens.cardFill,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(top: BorderSide(color: RideBookingTokens.border)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Cancel ride?',
                      style: TextStyle(
                        color: RideBookingTokens.titleWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    TextButton(onPressed: onClose, child: const Text('Skip')),
                  ],
                ),
                const Text(
                  'Why do you want to cancel?',
                  style: TextStyle(color: RideBookingTokens.titleWhite),
                ),
                const SizedBox(height: 16),
                for (final r in reasons)
                  ListTile(
                    leading: Text(r.$1, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      r.$2,
                      style: const TextStyle(
                        color: RideBookingTokens.titleWhite,
                      ),
                    ),
                    onTap: () => onSelect(r.$2),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Keep my ride',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CancelConfirmDialog extends StatelessWidget {
  const _CancelConfirmDialog({
    required this.driverName,
    required this.onClose,
    required this.onYesCancel,
    required this.onFindAnother,
    required this.onNo,
  });

  final String driverName;
  final VoidCallback onClose;
  final VoidCallback onYesCancel;
  final VoidCallback onFindAnother;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    final firstName = driverName.split(' ').first;

    return Stack(
      children: [
        Container(color: Colors.black.withValues(alpha: 0.8)),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                const Text(
                  'Cancel ride?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF2F6BFF), Color(0xFF4D7DFF)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('👤', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cancel your ride with $firstName?',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onYesCancel,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'YES, CANCEL',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: onFindAnother,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'FIND ANOTHER DRIVER',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(onPressed: onNo, child: const Text('NO')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
