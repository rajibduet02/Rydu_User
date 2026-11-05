import 'package:flutter/material.dart';

import '../../../../core/widgets/app_logo.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return AppLogo(width: width);
  }
}
