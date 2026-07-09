import 'package:flutter/material.dart';

import '../theme/saved_places_tokens.dart';

/// Dashed outline "Add New Place" row (Figma).
class AddNewPlaceCard extends StatelessWidget {
  const AddNewPlaceCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final padV = (w * 0.045).clamp(16.0, 20.0);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          foregroundPainter: _DashedRRectPainter(
            color: SavedPlacesTokens.accent.withValues(alpha: 0.55),
            borderRadius: radius,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: padV),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: SavedPlacesTokens.accent,
                  size: (w * 0.055).clamp(22.0, 26.0),
                ),
                SizedBox(width: (w * 0.02).clamp(8.0, 10.0)),
                Text(
                  'Add New Place',
                  style: TextStyle(
                    color: SavedPlacesTokens.white,
                    fontWeight: FontWeight.w600,
                    fontSize: (w * 0.042).clamp(15.0, 17.0),
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

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.borderRadius});

  final Color color;
  final double borderRadius;
  static const double _strokeWidth = 1.2;
  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = _strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = dist + _dash;
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
