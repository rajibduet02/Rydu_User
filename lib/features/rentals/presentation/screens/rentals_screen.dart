import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rentals_provider.dart';
import '../theme/rentals_tokens.dart';
import '../widgets/rentals_bottom_panel.dart';
import '../widgets/rentals_hero_section.dart';

class RentalsScreen extends ConsumerWidget {
  const RentalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = MediaQuery.sizeOf(context).height;
    final heroH = (h * RentalsTokens.heroFraction).clamp(260.0, 340.0);
    final s = ref.watch(rentalsControllerProvider);
    final c = ref.read(rentalsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: RentalsTokens.heroBottom,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RentalsHeroSection(height: heroH, onBack: c.navigateBack),
          Expanded(
            child: RentalsBottomPanel(
              errorMessage: s.errorMessage,
              onGetStarted: c.startRentalBooking,
            ),
          ),
        ],
      ),
    );
  }
}
