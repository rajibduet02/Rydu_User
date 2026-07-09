import 'package:flutter/material.dart';

import '../theme/safety_resources_tokens.dart';

class SafetyResourceCard extends StatelessWidget {
  const SafetyResourceCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: SafetyResourcesTokens.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: SafetyResourcesTokens.border),
      ),
      child: child,
    );
  }
}
