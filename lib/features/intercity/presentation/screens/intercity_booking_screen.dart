import 'package:flutter/material.dart';

import '../models/intercity_booking_route_args.dart';
import '../theme/intercity_tokens.dart';

/// Placeholder until full intercity booking flow is implemented.
class IntercityBookingScreen extends StatelessWidget {
  const IntercityBookingScreen({super.key, required this.routeArgs});

  final IntercityBookingRouteArgs routeArgs;

  @override
  Widget build(BuildContext context) {
    final a = routeArgs;
    return Scaffold(
      backgroundColor: IntercityTokens.background,
      appBar: AppBar(
        backgroundColor: IntercityTokens.background,
        foregroundColor: IntercityTokens.white,
        elevation: 0,
        title: const Text('Intercity booking'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: !a.hasDestination
              ? const Center(
                  child: Text(
                    'Search intercity rides.\n\n'
                    'Select a destination from the hub or use Search rides.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: IntercityTokens.muted,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        a.cityName ?? 'Destination',
                        style: const TextStyle(
                          color: IntercityTokens.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (a.startingPrice != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          a.startingPrice!,
                          style: const TextStyle(
                            color: IntercityTokens.muted,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'TODO: Date, seats, and payment when backend is ready.',
                        style: TextStyle(
                          color: IntercityTokens.muted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
