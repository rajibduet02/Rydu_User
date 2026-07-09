import 'package:flutter/material.dart';

import '../theme/rentals_tokens.dart';

/// Light hero area with back control and composed illustration (placeholder until final art).
class RentalsHeroSection extends StatelessWidget {
  const RentalsHeroSection({
    super.key,
    required this.height,
    required this.onBack,
  });

  final double height;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final hPad = (MediaQuery.sizeOf(context).width * 0.06).clamp(20.0, 24.0);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [RentalsTokens.heroTop, RentalsTokens.heroBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBack,
                    customBorder: const CircleBorder(),
                    child: Ink(
                      width: RentalsTokens.backButtonSize,
                      height: RentalsTokens.backButtonSize,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: RentalsTokens.backFill,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: RentalsTokens.titleWhite,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 280,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.15,
                        child: CustomPaint(
                          painter: _RentalsIllustrationPainter(),
                          // TODO: Replace custom vector placeholder with final marketing asset when available.
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RentalsIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final skyH = h * 0.34;
    final skyTop = h - skyH;

    final skyPaint = Paint()
      ..color = RentalsTokens.skylineGray.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final buildings = <({double x, double bw, double bh})>[
      (x: w * 0.05, bw: w * 0.1, bh: skyH * 0.6),
      (x: w * 0.175, bw: w * 0.125, bh: skyH * 0.8),
      (x: w * 0.325, bw: w * 0.09, bh: skyH * 0.5),
      (x: w * 0.4375, bw: w * 0.11, bh: skyH * 0.9),
      (x: w * 0.575, bw: w * 0.1, bh: skyH * 0.65),
      (x: w * 0.7, bw: w * 0.125, bh: skyH * 0.75),
      (x: w * 0.85, bw: w * 0.09, bh: skyH * 0.55),
    ];
    for (final b in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(b.x, skyTop + skyH - b.bh, b.bw, b.bh),
          const Radius.circular(2),
        ),
        skyPaint,
      );
    }

    final carCx = w * 0.46;
    final carBottom = h * 0.92;
    final carBody = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(carCx, carBottom - 18),
        width: w * 0.52,
        height: h * 0.16,
      ),
      Radius.circular(h * 0.08),
    );
    final bodyFill = Paint()..color = RentalsTokens.carBody;
    final bodyStroke = Paint()
      ..color = RentalsTokens.carStroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(carBody, bodyFill);
    canvas.drawRRect(carBody, bodyStroke);

    final cabin = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(carCx, carBottom - 42),
        width: w * 0.38,
        height: h * 0.14,
      ),
      Radius.circular(h * 0.06),
    );
    canvas.drawRRect(cabin, bodyFill);
    canvas.drawRRect(cabin, bodyStroke);

    final winPaint = Paint()..color = RentalsTokens.windowBlue;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(carCx - w * 0.16, carBottom - 50, w * 0.14, h * 0.08),
        Radius.circular(4),
      ),
      winPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(carCx + w * 0.02, carBottom - 50, w * 0.14, h * 0.08),
        Radius.circular(4),
      ),
      winPaint,
    );

    final wheelR = h * 0.055;
    for (final ox in [carCx - w * 0.18, carCx + w * 0.18]) {
      canvas.drawCircle(
        Offset(ox, carBottom - 6),
        wheelR,
        Paint()..color = RentalsTokens.wheelOuter,
      );
      canvas.drawCircle(
        Offset(ox, carBottom - 6),
        wheelR * 0.55,
        Paint()..color = RentalsTokens.wheelInner,
      );
    }

    final px = w * 0.78;
    final py = carBottom - 72;
    canvas.drawCircle(
      Offset(px, py),
      h * 0.045,
      Paint()..color = RentalsTokens.personHead,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(px, py + h * 0.1),
          width: w * 0.07,
          height: h * 0.18,
        ),
        Radius.circular(h * 0.035),
      ),
      Paint()..color = RentalsTokens.personBody,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px - w * 0.06, py + h * 0.12, w * 0.04, h * 0.14),
        Radius.circular(3),
      ),
      Paint()..color = RentalsTokens.personBody,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px + w * 0.02, py + h * 0.12, w * 0.04, h * 0.14),
        Radius.circular(3),
      ),
      Paint()..color = RentalsTokens.personBody,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px - w * 0.02, py + h * 0.28, w * 0.035, h * 0.12),
        Radius.circular(2),
      ),
      Paint()..color = RentalsTokens.personLeg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(px + w * 0.005, py + h * 0.28, w * 0.035, h * 0.12),
        Radius.circular(2),
      ),
      Paint()..color = RentalsTokens.personLeg,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
