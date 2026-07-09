import 'package:flutter/material.dart';

import 'welcome_ride_card.dart';

/// Center hero card (delegates to [WelcomeRideCard]).
class WelcomeHeroSection extends StatelessWidget {
  const WelcomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: WelcomeRideCard());
  }
}
