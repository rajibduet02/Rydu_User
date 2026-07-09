import 'package:flutter/material.dart';

import '../theme/reserve_tokens.dart';

/// Hero image with bottom fade into [ReserveTokens.background] and overlaid back control.
class ReserveHeaderImage extends StatelessWidget {
  const ReserveHeaderImage({
    super.key,
    required this.height,
    required this.onBack,
  });

  final double height;
  final VoidCallback onBack;

  static const String _placeholderHeroUrl =
      'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=800&h=600&fit=crop';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: Swap network hero for bundled night-driving asset when design provides it.
          Image.network(
            _placeholderHeroUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: ReserveTokens.iconWell,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: ReserveTokens.accentBlue,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: ReserveTokens.iconWell,
                alignment: Alignment.center,
                child: Icon(
                  Icons.directions_car_outlined,
                  size: 56,
                  color: ReserveTokens.white.withValues(alpha: 0.35),
                ),
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  ReserveTokens.background,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBack,
                    customBorder: const CircleBorder(),
                    child: Ink(
                      width: ReserveTokens.backButtonSize,
                      height: ReserveTokens.backButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ReserveTokens.backFill,
                        border: Border.all(color: ReserveTokens.backBorder),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: ReserveTokens.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
