import 'package:flutter/material.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key, this.rideId});

  final String? rideId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Ride Details ${rideId ?? ''}')));
  }
}
