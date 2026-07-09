import 'package:flutter/material.dart';

import '../theme/add_card_tokens.dart';

class CardPreview extends StatelessWidget {
  const CardPreview({
    super.key,
    required this.cardNumberDisplay,
    required this.cardholderDisplay,
    required this.expiryDisplay,
  });

  /// Formatted groups or masked dots for number line.
  final String cardNumberDisplay;
  final String cardholderDisplay;
  final String expiryDisplay;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final numberSize = (w * 0.055).clamp(20.0, 24.0);
    final small = (w * 0.028).clamp(10.0, 11.0);
    final label = (w * 0.028).clamp(10.0, 11.0);
    final value = (w * 0.035).clamp(13.0, 14.0);

    return Container(
      height: (w * 0.42).clamp(180.0, 208.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AddCardTokens.accent, AddCardTokens.accentEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AddCardTokens.accent.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.credit_card_rounded,
                      color: AddCardTokens.white.withValues(alpha: 0.85),
                      size: 44,
                    ),
                    Text(
                      'DEBIT',
                      style: TextStyle(
                        color: AddCardTokens.white.withValues(alpha: 0.85),
                        fontSize: small,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  cardNumberDisplay,
                  style: TextStyle(
                    color: AddCardTokens.white,
                    fontSize: numberSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARDHOLDER',
                          style: TextStyle(
                            color: AddCardTokens.white.withValues(alpha: 0.6),
                            fontSize: label,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cardholderDisplay,
                          style: TextStyle(
                            color: AddCardTokens.white,
                            fontSize: value,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: AddCardTokens.white.withValues(alpha: 0.6),
                            fontSize: label,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expiryDisplay,
                          style: TextStyle(
                            color: AddCardTokens.white,
                            fontSize: value,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.08);
    const step = 40.0;
    for (var x = 0.0; x < size.width; x += step) {
      for (var y = 0.0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x + 20, y + 20), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
