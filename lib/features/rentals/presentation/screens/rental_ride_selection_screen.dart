import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/rental_ride_selection_provider.dart';
import '../theme/rental_ride_tokens.dart';
import '../../../payment/presentation/widgets/payment_method_sheet.dart';
import '../../../payment/presentation/providers/payment_method_provider.dart';
import '../widgets/rental_payment_method_card.dart';
import '../widgets/rental_promotion_banner.dart';
import '../widgets/rental_vehicle_card.dart';

class RentalRideSelectionScreen extends ConsumerStatefulWidget {
  const RentalRideSelectionScreen({super.key});

  @override
  ConsumerState<RentalRideSelectionScreen> createState() =>
      _RentalRideSelectionScreenState();
}

class _RentalRideSelectionScreenState
    extends ConsumerState<RentalRideSelectionScreen> {
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
        .read(rentalRideSelectionControllerProvider.notifier)
        .initializeFromExtra(map);
  }

  Future<void> _openPaymentMethodModal() async {
    await PaymentMethodSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(rentalRideSelectionControllerProvider);
    final payment = ref.watch(paymentMethodControllerProvider);
    final c = ref.read(rentalRideSelectionControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final selected = s.selectedVehicle;

    return Scaffold(
      backgroundColor: RentalRideTokens.sheetBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 16),
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: c.navigateBack,
                      customBorder: const CircleBorder(),
                      child: Ink(
                        width: RentalRideTokens.backSize,
                        height: RentalRideTokens.backSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF3F4F6),
                          border: Border.all(
                            color: RentalRideTokens.sheetBorder,
                          ),
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: RentalRideTokens.sheetTitle,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RentalPromotionBanner(promotionAmount: s.promotionAmount),
                  const SizedBox(height: 22),
                  Text(
                    "Rides we think you'll like",
                    style: TextStyle(
                      color: RentalRideTokens.sheetTitle,
                      fontSize: (w * 0.045).clamp(17.0, 18.0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...s.rentalVehicles.map(
                    (v) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RentalVehicleCard(
                        vehicle: v,
                        selected: v.id == s.selectedVehicleId,
                        onTap: () => c.selectVehicle(v.id),
                      ),
                    ),
                  ),
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
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: RentalRideTokens.sheetBackground,
                border: Border(
                  top: BorderSide(
                    color: RentalRideTokens.sheetBorder,
                    width: 1,
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16 + bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RentalPaymentMethodCard(
                    label: payment.selectedPaymentMethod,
                    onTap: _openPaymentMethodModal,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: selected == null
                        ? null
                        : c.chooseSelectedVehicle,
                    style: FilledButton.styleFrom(
                      backgroundColor: RentalRideTokens.sheetCta,
                      foregroundColor: RentalRideTokens.white,
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      disabledForegroundColor: RentalRideTokens.sheetMuted,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          RentalRideTokens.ctaRadius,
                        ),
                      ),
                      minimumSize: Size(
                        double.infinity,
                        (w * 0.14).clamp(52.0, 56.0),
                      ),
                    ),
                    child: Text(
                      selected == null
                          ? 'Choose a ride'
                          : 'Choose ${selected.name}',
                      style: TextStyle(
                        fontSize: (w * 0.045).clamp(16.0, 18.0),
                        fontWeight: FontWeight.w700,
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
