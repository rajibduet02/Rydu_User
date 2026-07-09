import 'package:flutter/material.dart';

import '../theme/email_support_tokens.dart';

class EmailAttachmentBox extends StatelessWidget {
  const EmailAttachmentBox({
    super.key,
    required this.onTap,
    this.attachmentPath,
    this.onRemove,
  });

  final VoidCallback onTap;
  final String? attachmentPath;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.028).clamp(10.0, 11.0);
    final bodySize = (w * 0.035).clamp(13.0, 14.0);
    final radius = (w * 0.03).clamp(10.0, 12.0);
    final hasFile = attachmentPath != null && attachmentPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ATTACHMENT',
          style: TextStyle(
            color: EmailSupportTokens.label,
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: CustomPaint(
              foregroundPainter: _DashedBorderPainter(
                color: EmailSupportTokens.border,
                borderRadius: radius,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: (w * 0.06).clamp(22.0, 28.0),
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      color: EmailSupportTokens.orange,
                      size: (w * 0.07).clamp(26.0, 30.0),
                    ),
                    SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
                    Text(
                      hasFile
                          ? 'File attached (tap to change)'
                          : 'Attach screenshot or file',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: EmailSupportTokens.muted,
                        fontSize: bodySize,
                      ),
                    ),
                    if (hasFile && onRemove != null) ...[
                      SizedBox(height: 8),
                      TextButton(
                        onPressed: onRemove,
                        child: Text(
                          'Remove',
                          style: TextStyle(
                            color: EmailSupportTokens.accent,
                            fontSize: bodySize,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
    const dash = 6.0;
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
