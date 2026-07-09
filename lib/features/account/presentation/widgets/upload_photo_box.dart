import 'package:flutter/material.dart';

import '../theme/report_ride_issue_tokens.dart';

enum UploadPhotoBoxKind { camera, gallery, preview }

class UploadPhotoBox extends StatelessWidget {
  const UploadPhotoBox({
    super.key,
    required this.kind,
    this.onTap,
    this.onRemove,
  });

  final UploadPhotoBoxKind kind;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = (w * 0.26).clamp(96.0, 108.0);
    final radius = (w * 0.03).clamp(10.0, 12.0);
    final labelSize = (w * 0.032).clamp(12.0, 13.0);

    if (kind == UploadPhotoBoxKind.preview) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: ReportRideIssueTokens.iconWell,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: ReportRideIssueTokens.border),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.receipt_long_outlined,
              color: ReportRideIssueTokens.muted,
              size: size * 0.4,
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: Colors.redAccent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final isCamera = kind == UploadPhotoBoxKind.camera;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: ReportRideIssueTokens.border,
            borderRadius: radius,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCamera
                      ? Icons.photo_camera_outlined
                      : Icons.photo_library_outlined,
                  color: ReportRideIssueTokens.muted,
                  size: (w * 0.065).clamp(24.0, 28.0),
                ),
                SizedBox(height: (w * 0.015).clamp(6.0, 8.0)),
                Text(
                  isCamera ? 'Camera' : 'Gallery',
                  style: TextStyle(
                    color: ReportRideIssueTokens.muted,
                    fontSize: labelSize,
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

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.borderRadius});

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius;
  }
}
