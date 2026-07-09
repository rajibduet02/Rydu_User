import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rental_time_controller.dart';
import '../providers/rental_time_provider.dart';
import '../theme/rental_time_tokens.dart';
import '../widgets/rental_leave_option_button.dart';
import '../widgets/rental_price_summary.dart';
import '../widgets/rental_time_selector.dart';

class RentalTimeSelectionScreen extends ConsumerWidget {
  const RentalTimeSelectionScreen({super.key});

  static const double _hourlyDiscount = 389.25;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(rentalTimeControllerProvider);
    final c = ref.read(rentalTimeControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.075).clamp(26.0, 30.0);

    return Scaffold(
      backgroundColor: RentalTimeTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: c.navigateBack,
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: RentalTimeTokens.backSize,
                          height: RentalTimeTokens.backSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: RentalTimeTokens.panelFill,
                            border: Border.all(color: RentalTimeTokens.border),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: RentalTimeTokens.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'How much time do\nyou need?',
                      style: TextStyle(
                        color: RentalTimeTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: (w * 0.08).clamp(28.0, 40.0)),
                    RentalTimeSelector(
                      hours: s.selectedHours,
                      includedKm: s.includedKm,
                      minHours: s.minHours,
                      maxHours: s.maxHours,
                      onDecrease: c.decreaseHours,
                      onIncrease: c.increaseHours,
                      onSliderChanged: (v) => c.updateHours(v.round()),
                    ),
                    SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                    Row(
                      children: [
                        RentalLeaveOptionButton(
                          label: 'Leave now',
                          selected:
                              s.selectedLeaveOption == RentalLeaveOptions.now,
                          onTap: () =>
                              c.selectLeaveOption(RentalLeaveOptions.now),
                        ),
                        SizedBox(width: (w * 0.02).clamp(10.0, 12.0)),
                        RentalLeaveOptionButton(
                          label: 'Leave later',
                          selected:
                              s.selectedLeaveOption == RentalLeaveOptions.later,
                          onTap: () =>
                              c.selectLeaveOption(RentalLeaveOptions.later),
                        ),
                      ],
                    ),
                    if (s.errorMessage != null) ...[
                      const SizedBox(height: 16),
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
            ),
            RentalPriceSummary(
              currentTotal: s.currentPrice,
              originalTotal: s.originalPrice,
              hourlyRateLabel: 'BDT${_hourlyDiscount.toStringAsFixed(2)} /hour',
              onChooseRide: c.chooseRide,
            ),
          ],
        ),
      ),
    );
  }
}
