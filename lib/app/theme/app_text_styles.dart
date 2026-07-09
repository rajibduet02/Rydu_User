import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared text styles; prefer [Theme.of(context).textTheme] for new code.
abstract final class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF),
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFFFFFFFF),
  );

  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppBrand.primary,
  );
}
