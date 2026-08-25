import 'package:flutter/material.dart';

import '../theme/ride_history_tokens.dart';
import '../widgets/ride_history_body.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: RideHistoryTokens.background,
      body: RideHistoryBody(
        title: 'Ride History',
        showBackButton: true,
      ),
    );
  }
}
