import 'package:flutter/material.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text(title));
  }
}
