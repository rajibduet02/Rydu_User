import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../models/ride_flow_extra.dart';
import '../models/ride_vehicle_option.dart';
import '../../../payment/presentation/providers/payment_method_provider.dart';
import '../../../payment/presentation/widgets/payment_method_sheet.dart';
import '../providers/ride_booking_provider.dart';
import '../theme/ride_booking_tokens.dart';
import '../widgets/payment_method_tile.dart';
import '../widgets/ride_option_card.dart';

class RideSelectionScreen extends ConsumerStatefulWidget {
  const RideSelectionScreen({super.key});

  @override
  ConsumerState<RideSelectionScreen> createState() =>
      _RideSelectionScreenState();
}

class _RideSelectionScreenState extends ConsumerState<RideSelectionScreen> {
  bool _initialized = false;

  static const _categories = ['recommended', 'premier', 'popular', 'economy'];

  String _categoryTitle(String category) {
    switch (category) {
      case 'recommended':
        return 'Rides we think you\'ll like';
      case 'premier':
        return 'Premier';
      case 'popular':
        return 'Popular';
      case 'economy':
        return 'Economy';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideBookingControllerProvider);
    final payment = ref.watch(paymentMethodControllerProvider);
    final c = ref.read(rideBookingControllerProvider.notifier);
    final options = state.rideOptions;

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final extra = GoRouterState.of(context).extra;
        c.initializeFromExtra(RideFlowExtra.parseMap(extra)).then((_) {
          if (!mounted) return;
          if (ref.read(rideBookingControllerProvider).selectedVehicleId ==
              null) {
            c.selectVehicle('cng');
          }
        });
      });
    }

    final grouped = <String, List<RideVehicleOption>>{};
    for (final o in options) {
      grouped.putIfAbsent(o.category, () => []).add(o);
    }

    final selectedName = state.selectedVehicle?.name ?? 'Ride';
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: RideBookingTokens.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                _MapHeader(
                  destinationName: state.selectedDestination?.name,
                  onBack: () {
                    if (context.canPop()) context.pop();
                  },
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -32),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: RideBookingTokens.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          24,
                          16,
                          200 + bottomInset,
                        ),
                        children: [
                          for (final category in _categories) ...[
                            if (grouped[category]?.isNotEmpty ?? false) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                                child: Text(
                                  _categoryTitle(category),
                                  style: const TextStyle(
                                    color: RideBookingTokens.muted,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              for (final option in grouped[category]!)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: RideOptionCard(
                                    option: option,
                                    isSelected:
                                        state.selectedVehicleId == option.id,
                                    onTap: () => c.selectVehicle(option.id),
                                  ),
                                ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
                decoration: const BoxDecoration(
                  color: RideBookingTokens.background,
                  border: Border(
                    top: BorderSide(color: RideBookingTokens.border),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PaymentMethodTile(
                      method: payment.selectedPaymentMethod,
                      onTap: () async {
                        await PaymentMethodSheet.show(context);
                        if (!context.mounted) return;
                        c.syncPaymentFromProvider();
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: state.hasSelectedVehicle
                            ? c.continueToConfirmPickup
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor:
                              AppDarkSurfaces.surfaceContainerLow,
                          disabledForegroundColor: RideBookingTokens.muted,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Choose $selectedName',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
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

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.onBack, this.destinationName});

  final VoidCallback onBack;
  final String? destinationName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 256,
      child: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppDarkSurfaces.surfaceContainerLow,
                  RideBookingTokens.background,
                ],
              ),
            ),
            child: SizedBox.expand(),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBack,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B2C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '30% promotion applied',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.2,
              child: CustomPaint(
                size: const Size(200, 150),
                painter: _RoutePainter(),
              ),
            ),
          ),
          if (destinationName != null)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Text(
                destinationName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RideBookingTokens.muted,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

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
            color: RideBookingTokens.headerButtonFill,
            border: Border.all(color: RideBookingTokens.border),
          ),
          child: Icon(icon, color: RideBookingTokens.titleWhite, size: 22),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RideBookingTokens.accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(30, size.height - 30)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.25,
        size.width - 30,
        30,
      );
    paint.strokeCap = StrokeCap.round;
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }

    final dot = Paint()..color = RideBookingTokens.accent;
    canvas.drawCircle(Offset(30, size.height - 30), 6, dot);
    canvas.drawCircle(Offset(size.width - 30, 30), 6, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
