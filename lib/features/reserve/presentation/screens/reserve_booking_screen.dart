import 'package:flutter/material.dart';

import '../models/reserve_booking_route_args.dart';
import '../theme/reserve_tokens.dart';

/// Placeholder until reserve date/time and vehicle flow is implemented.
class ReserveBookingScreen extends StatelessWidget {
  const ReserveBookingScreen({super.key, required this.routeArgs});

  final ReserveBookingRouteArgs routeArgs;

  @override
  Widget build(BuildContext context) {
    final a = routeArgs;
    final hasSelection =
        (a.pickupDateIso != null && a.pickupDateIso!.isNotEmpty) ||
        (a.pickupTimeLabel != null && a.pickupTimeLabel!.isNotEmpty);

    return Scaffold(
      backgroundColor: ReserveTokens.background,
      appBar: AppBar(
        backgroundColor: ReserveTokens.background,
        foregroundColor: ReserveTokens.white,
        elevation: 0,
        title: const Text('Reserve booking'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: !hasSelection
              ? const Center(
                  child: Text(
                    'Pick a date and time on the next step.\n\n'
                    'TODO: Date/time picker and confirmation when product flow is ready.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ReserveTokens.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (a.pickupDateIso != null) ...[
                        const Text(
                          'Pickup date',
                          style: TextStyle(
                            color: ReserveTokens.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.pickupDateIso!,
                          style: const TextStyle(
                            color: ReserveTokens.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (a.pickupTimeLabel != null) ...[
                        const Text(
                          'Pickup time',
                          style: TextStyle(
                            color: ReserveTokens.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.pickupTimeLabel!,
                          style: const TextStyle(
                            color: ReserveTokens.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'TODO: Vehicle selection and payment when backend is ready.',
                        style: TextStyle(
                          color: ReserveTokens.white,
                          fontSize: 14,
                          height: 1.35,
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
