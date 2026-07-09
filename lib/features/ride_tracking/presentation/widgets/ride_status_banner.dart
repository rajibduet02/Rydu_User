import 'package:flutter/material.dart';

class RideStatusBanner extends StatelessWidget {
  const RideStatusBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.blue.shade50),
      child: Padding(padding: const EdgeInsets.all(12), child: Text(message)),
    );
  }
}
