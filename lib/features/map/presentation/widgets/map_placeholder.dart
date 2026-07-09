import 'package:flutter/material.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFE5E7EB),
      child: Center(child: Text('Map view')),
    );
  }
}
