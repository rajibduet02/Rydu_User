import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reserve_provider.dart';
import '../theme/reserve_tokens.dart';
import '../widgets/reserve_bottom_button.dart';
import '../widgets/reserve_feature_tile.dart';
import '../widgets/reserve_header_image.dart';

class ReserveScreen extends ConsumerWidget {
  const ReserveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    final heroH = (h * ReserveTokens.heroFraction).clamp(220.0, 360.0);
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final c = ref.read(reserveControllerProvider.notifier);
    final s = ref.watch(reserveControllerProvider);

    return Scaffold(
      backgroundColor: ReserveTokens.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReserveHeaderImage(height: heroH, onBack: c.navigateBack),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reserve',
                    style: TextStyle(
                      color: ReserveTokens.white,
                      fontSize: (w * 0.11).clamp(40.0, 48.0),
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const ReserveFeatureTile(
                    icon: Icons.calendar_today_outlined,
                    text:
                        'Choose your exact pickup time up to 90 days in advance',
                  ),
                  const SizedBox(height: 22),
                  const ReserveFeatureTile(
                    icon: Icons.schedule_outlined,
                    text: 'Extra wait time included to meet your ride',
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
                  SizedBox(height: 88 + bottomPad),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12 + bottomPad),
            child: ReserveBottomButton(onPressed: c.startReserveRide),
          ),
        ],
      ),
    );
  }
}
