import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/rental_driver_found_provider.dart';
import '../theme/rental_driver_found_tokens.dart';
import '../widgets/cancel_rental_bottom_sheet.dart';
import '../widgets/rental_details_card.dart';
import '../widgets/rental_driver_card.dart';
import '../widgets/rental_reminder_card.dart';

class RentalDriverFoundScreen extends ConsumerStatefulWidget {
  const RentalDriverFoundScreen({super.key});

  @override
  ConsumerState<RentalDriverFoundScreen> createState() =>
      _RentalDriverFoundScreenState();
}

class _RentalDriverFoundScreenState
    extends ConsumerState<RentalDriverFoundScreen> {
  var _routeExtraApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeExtraApplied) return;
    _routeExtraApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyRouteExtra();
    });
  }

  void _applyRouteExtra() {
    if (!mounted) return;
    final extra = GoRouterState.of(context).extra;
    final map = <String, dynamic>{};
    if (extra is Map) {
      extra.forEach((k, v) => map[k.toString()] = v);
    }
    ref
        .read(rentalDriverFoundControllerProvider.notifier)
        .initializeFromExtra(map);
  }

  Future<void> _openCancelSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) => CancelRentalBottomSheet(hostContext: context),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(rentalDriverFoundControllerProvider);
    final c = ref.read(rentalDriverFoundControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final mapH = (MediaQuery.sizeOf(context).height * 0.22).clamp(150.0, 190.0);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final durationLabel = s.rentalHours == 1
        ? '1 hour'
        : '${s.rentalHours} hours';

    return Scaffold(
      backgroundColor: RentalDriverFoundTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: mapH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            RentalDriverFoundTokens.mapTop,
                            RentalDriverFoundTokens.mapBottom,
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _MapGridPainter(),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: hPad,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: c.navigateBack,
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: RentalDriverFoundTokens.backSize,
                          height: RentalDriverFoundTokens.backSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: RentalDriverFoundTokens.card,
                            border: Border.all(
                              color: RentalDriverFoundTokens.border,
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: RentalDriverFoundTokens.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: hPad,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: RentalDriverFoundTokens.accent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Starting in ${s.startingInMinutes} min',
                        style: TextStyle(
                          color: RentalDriverFoundTokens.white,
                          fontSize: (w * 0.032).clamp(12.5, 13.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  decoration: const BoxDecoration(
                    color: RentalDriverFoundTokens.sheet,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                        RentalDriverFoundTokens.sheetTopRadius,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(
                        RentalDriverFoundTokens.sheetTopRadius,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.fromLTRB(hPad, 36, hPad, 12),
                            children: [
                              RentalReminderCard(
                                rentalHours: s.rentalHours,
                                includedKm: s.includedKm,
                              ),
                              const SizedBox(height: 20),
                              RentalDriverCard(
                                vehiclePlate: s.vehiclePlate,
                                driverName: s.driverName,
                                onChat: c.openChat,
                                onCall: () {
                                  final msg = c.callDriver();
                                  if (msg != null && context.mounted) {
                                    _showSnack(context, msg);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              RentalDetailsCard(
                                expanded: s.isDetailsExpanded,
                                onToggle: c.toggleDetails,
                                startingPoint: s.startingPoint,
                                rentalId: s.rentalId,
                                durationLabel: durationLabel,
                                paymentMethod: s.paymentMethod,
                                onShare: () {
                                  final msg = c.shareTripStatus();
                                  if (msg != null && context.mounted) {
                                    _showSnack(context, msg);
                                  }
                                },
                              ),
                              if (s.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  s.errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            hPad,
                            8,
                            hPad,
                            16 + bottom,
                          ),
                          child: OutlinedButton(
                            onPressed: () => _openCancelSheet(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: RentalDriverFoundTokens.white,
                              side: const BorderSide(
                                color: RentalDriverFoundTokens.border,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  RentalDriverFoundTokens.cardRadius,
                                ),
                              ),
                              minimumSize: Size(
                                double.infinity,
                                (w * 0.13).clamp(48.0, 52.0),
                              ),
                            ),
                            child: Text(
                              'Cancel rental',
                              style: TextStyle(
                                fontSize: (w * 0.04).clamp(15.0, 16.0),
                                fontWeight: FontWeight.w600,
                              ),
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
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1
      ..isAntiAlias = true;
    const bands = 5;
    for (var i = 0; i <= bands; i++) {
      final y = size.height / bands * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    for (var i = 0; i <= 8; i++) {
      final x = size.width / 8 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
