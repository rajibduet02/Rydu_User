import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../models/ride_flow_extra.dart';
import '../../../payment/presentation/providers/payment_method_provider.dart';
import '../../../payment/presentation/widgets/payment_method_sheet.dart';
import '../providers/ride_booking_provider.dart';
import '../theme/ride_booking_tokens.dart';
import '../widgets/payment_method_tile.dart';
import '../widgets/pickup_location_card.dart';

class ConfirmPickupScreen extends ConsumerStatefulWidget {
  const ConfirmPickupScreen({super.key});

  @override
  ConsumerState<ConfirmPickupScreen> createState() =>
      _ConfirmPickupScreenState();
}

class _ConfirmPickupScreenState extends ConsumerState<ConfirmPickupScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideBookingControllerProvider);
    final payment = ref.watch(paymentMethodControllerProvider);
    final c = ref.read(rideBookingControllerProvider.notifier);

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        c.initializeFromExtra(
          RideFlowExtra.parseMap(GoRouterState.of(context).extra),
        );
        unawaited(c.loadPickupSpots());
      });
    }

    final vehicle = state.selectedVehicle;
    final dest = state.selectedDestination?.name;
    final spots = state.pickupSpots;

    return Scaffold(
      backgroundColor: RideBookingTokens.background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppDarkSurfaces.border,
                          AppDarkSurfaces.surfaceContainerLow,
                        ],
                      ),
                    ),
                    child: SizedBox.expand(),
                  ),
                  Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 12,
                    left: 16,
                    child: _BackButton(
                      onTap: () {
                        if (context.canPop()) context.pop();
                      },
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: RideBookingTokens.accent,
                            boxShadow: [
                              BoxShadow(
                                color: RideBookingTokens.accent.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Pickup here',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: RideBookingTokens.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                  top: BorderSide(color: RideBookingTokens.border),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Confirm the pickup spot',
                          style: TextStyle(
                            color: RideBookingTokens.titleWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      _CircleIcon(icon: Icons.search_rounded, onTap: () {}),
                    ],
                  ),
                  if (vehicle != null || dest != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: RideBookingTokens.cardFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: RideBookingTokens.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vehicle != null)
                            Text(
                              '${vehicle.name} · ${state.estimatedFare ?? vehicle.price}',
                              style: const TextStyle(
                                color: RideBookingTokens.titleWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (dest != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'To $dest',
                              style: const TextStyle(
                                color: RideBookingTokens.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  PaymentMethodTile(
                    method: payment.selectedPaymentMethod,
                    onTap: () async {
                      await PaymentMethodSheet.show(context);
                      if (!context.mounted) return;
                      c.syncPaymentFromProvider();
                    },
                  ),
                  const SizedBox(height: 20),
                  if (state.isLoadingPickupSpots)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (spots.isEmpty)
                    PickupLocationCard(
                      name: state.pickupLocation.isNotEmpty
                          ? state.pickupLocation
                          : 'Selected pickup',
                      address: state.pickupPlace?.address ?? '',
                      isSelected: true,
                      onTap: () {},
                    )
                  else
                    for (var i = 0; i < spots.length; i++) ...[
                      PickupLocationCard(
                        name: spots[i].label,
                        address: spots[i].address ?? spots[i].label,
                        isSelected: state.selectedPickupSpotIndex == i,
                        onTap: () => c.selectPickupSpot(i),
                      ),
                      if (i < spots.length - 1) const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.isLoading || state.isCreatingBooking
                          ? null
                          : c.confirmPickup,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Confirm pickup',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                    ),
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RideBookingTokens.headerButtonFill,
            border: Border.all(color: RideBookingTokens.border),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            color: RideBookingTokens.titleWhite,
            size: 26,
          ),
        ),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RideBookingTokens.cardFill,
            border: Border.all(color: RideBookingTokens.border),
          ),
          child: Icon(icon, color: RideBookingTokens.muted, size: 22),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    for (var i = 0; i < 20; i++) {
      final y = i * 50.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      final x = i * 50.0;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
