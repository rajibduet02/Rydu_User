import 'package:flutter/material.dart';

import '../theme/finding_driver_tokens.dart';

/// Pulsing radar circles behind the car icon (React `FindingDriverScreen`).
class FindingDriverAnimation extends StatefulWidget {
  const FindingDriverAnimation({super.key});

  @override
  State<FindingDriverAnimation> createState() => _FindingDriverAnimationState();
}

class _FindingDriverAnimationState extends State<FindingDriverAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.sizeOf(context).width * 0.64).clamp(220.0, 256.0);

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              _PulseRing(
                size: size,
                progress: t,
                delay: 0,
                color: FindingDriverTokens.accent,
                minOpacity: 0.2,
                maxOpacity: 0.5,
                maxScale: 1.5,
              ),
              _PulseRing(
                size: size,
                progress: t,
                delay: 0.25,
                color: FindingDriverTokens.accentLight,
                minOpacity: 0.1,
                maxOpacity: 0.35,
                maxScale: 1.3,
                inset: size * 0.06,
              ),
              child!,
            ],
          );
        },
        child: const Text(
          // TODO: Replace with branded car asset when available.
          '🚗',
          style: TextStyle(fontSize: 56),
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.size,
    required this.progress,
    required this.delay,
    required this.color,
    required this.minOpacity,
    required this.maxOpacity,
    required this.maxScale,
    this.inset = 0,
  });

  final double size;
  final double progress;
  final double delay;
  final Color color;
  final double minOpacity;
  final double maxOpacity;
  final double maxScale;
  final double inset;

  @override
  Widget build(BuildContext context) {
    final p = ((progress + delay) % 1.0);
    final scale = 1.0 + (maxScale - 1.0) * Curves.easeInOut.transform(p);
    final opacity = minOpacity + (maxOpacity - minOpacity) * (1 - p);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: size - inset * 2,
        height: size - inset * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}
