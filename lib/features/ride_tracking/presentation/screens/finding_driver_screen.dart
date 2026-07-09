import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ride_booking/presentation/models/ride_flow_extra.dart';
import '../providers/finding_driver_provider.dart';
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

  @override
  void dispose() {
    ref.read(findingDriverControllerProvider.notifier).stopSearching();
    super.dispose();
  }

  Future<void> _runSearchFlow() async {
    final c = ref.read(findingDriverControllerProvider.notifier);
    c.startSearching();

    // TODO: Replace timed delay with real driver-matching API / websocket updates.
    await Future<void>.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    c.navigateToDriverFound();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(findingDriverControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.055).clamp(22.0, 24.0);
    final subtitleSize = (w * 0.038).clamp(14.0, 15.0);

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(findingDriverControllerProvider.notifier)
            .initializeFromExtra(
              RideFlowExtra.parseMap(GoRouterState.of(context).extra),
            );
        _runSearchFlow();
      });
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: FindingDriverTokens.background,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: (w * 0.48).clamp(180.0, 192.0),
                child: Stack(
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            FindingDriverTokens.mapTop,
                            FindingDriverTokens.mapBottom,
                          ],
                        ),
                      ),
                      child: SizedBox.expand(),
                    ),
                    Positioned.fill(
                      child: CustomPaint(painter: _MapGridPainter()),
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
                            'Ride requested',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FindingDriverTokens.white,
                              fontWeight: FontWeight.w700,
                              fontSize: titleSize,
                            ),
                          ),
                          SizedBox(height: (w * 0.015).clamp(6.0, 8.0)),
                          Text(
                            'Finding drivers nearby',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: FindingDriverTokens.muted,
                              fontSize: subtitleSize,
                            ),
                          ),
                          SizedBox(height: (w * 0.06).clamp(24.0, 32.0)),
                          const FindingDriverAnimation(),
                          SizedBox(height: (w * 0.06).clamp(24.0, 32.0)),
                          RideRequestedCard(
                            pickupSpotName: state.pickupSpotName,
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    for (var i = 0; i < 10; i++) {
      final y = i * 50.0;
      if (y <= size.height) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
