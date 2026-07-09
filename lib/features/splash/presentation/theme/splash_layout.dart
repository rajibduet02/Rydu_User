import 'package:flutter/material.dart';

/// Responsive metrics for splash layout.
abstract final class SplashLayout {
  static const double maxContentWidth = 448;
  static const double horizontalPadding = 24;

  /// Gap title → tagline (reference: moderate).
  static const double spacingLogoToTagline = 22;

  /// Gap tagline → dots.
  static double spacingTaglineToDots(double viewportHeight) {
    return viewportHeight < 560 ? 40 : 48;
  }

  static double logoFontSize(double width) {
    return (width * 0.195).clamp(56.0, 92.0);
  }

  /// ~1/3–1/4 of logo size visually.
  static double taglineFontSize(double width) {
    return (width * 0.048).clamp(17.0, 22.0);
  }

  static double dotSize(double width) {
    return (width * 0.032).clamp(10.0, 14.0);
  }

  static double dotGap(double width) {
    return (width * 0.03).clamp(10.0, 12.0);
  }

  static double easeInOutTriangle(double t) {
    final u = (t % 1.0) * 2;
    final x = u <= 1 ? u : 2 - u;
    return Curves.easeInOut.transform(x);
  }
}
