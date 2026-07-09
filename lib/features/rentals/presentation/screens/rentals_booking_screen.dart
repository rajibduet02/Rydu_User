import 'package:flutter/material.dart';

import '../models/rentals_booking_route_args.dart';
import '../theme/rentals_tokens.dart';

/// Placeholder until rental duration / vehicle selection is implemented.
class RentalsBookingScreen extends StatelessWidget {
  const RentalsBookingScreen({super.key, required this.routeArgs});

  final RentalsBookingRouteArgs routeArgs;

  @override
  Widget build(BuildContext context) {
    final id = routeArgs.packageId;

    return Scaffold(
      backgroundColor: RentalsTokens.panelBg,
      appBar: AppBar(
        backgroundColor: RentalsTokens.panelBg,
        foregroundColor: RentalsTokens.titleWhite,
        elevation: 0,
        title: const Text('Rentals booking'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                id == null || id.isEmpty
                    ? 'Choose a rental package on the next steps.'
                    : 'Package: $id',
                style: const TextStyle(
                  color: RentalsTokens.bodyText,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TODO: Duration, vehicle class, and driver assignment when backend is ready.',
                style: TextStyle(color: RentalsTokens.bodyText, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
