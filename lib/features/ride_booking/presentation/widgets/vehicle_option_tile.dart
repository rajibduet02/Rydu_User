import 'package:flutter/material.dart';

class VehicleOptionTile extends StatelessWidget {
  const VehicleOptionTile({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(label), onTap: onTap);
  }
}
