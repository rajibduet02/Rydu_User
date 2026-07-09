import 'package:flutter/material.dart';

import '../models/select_vehicle_route_args.dart';

class SelectVehicleScreen extends StatelessWidget {
  const SelectVehicleScreen({super.key, this.routeArgs});

  final SelectVehicleRouteArgs? routeArgs;

  @override
  Widget build(BuildContext context) {
    final a = routeArgs;
    return Scaffold(
      appBar: AppBar(title: const Text('Select vehicle')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: a == null
              ? const Center(
                  child: Text(
                    'Select Vehicle\n\n'
                    'Open this screen from Plan your ride after choosing a destination.',
                    textAlign: TextAlign.center,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ride type: ${a.selectedRideType}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Text('Pickup: ${a.pickupAddress}'),
                      const SizedBox(height: 12),
                      Text('Destination: ${a.destinationName ?? '—'}'),
                      if (a.destinationAddress != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          a.destinationAddress!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'TODO: Vehicle list and pricing when backend is ready.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
