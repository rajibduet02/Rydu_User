import 'package:flutter/material.dart';

import '../theme/splash_layout.dart';
import '../theme/splash_tokens.dart';

/// Three staggered pulsing dots (solid blue per reference).
class SplashLoadingDots extends StatefulWidget {
  const SplashLoadingDots({
    super.key,
    required this.dotSize,
    required this.gap,
  });

  final double dotSize;
  final double gap;

  @override
  State<SplashLoadingDots> createState() => _SplashLoadingDotsState();
}

class _SplashLoadingDotsState extends State<SplashLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (t + i * 0.15) % 1.0;
            final wave = SplashLayout.easeInOutTriangle(phase);
            final scale = 1.0 + 0.22 * wave;
            final opacity = 0.45 + 0.55 * wave;
            return Padding(
              padding: EdgeInsets.only(right: i < 2 ? widget.gap : 0),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: SplashTokens.dotBlue,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
