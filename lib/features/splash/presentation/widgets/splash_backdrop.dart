import 'package:flutter/material.dart';

import '../theme/splash_tokens.dart';

/// Flat splash background (reference: solid dark navy).
class SplashBackdrop extends StatelessWidget {
  const SplashBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: SplashTokens.background);
  }
}
