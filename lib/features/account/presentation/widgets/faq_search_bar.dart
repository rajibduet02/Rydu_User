import 'package:flutter/material.dart';

import '../theme/faqs_tokens.dart';

class FaqSearchBar extends StatelessWidget {
  const FaqSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.08).clamp(28.0, 32.0);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        color: FaqsTokens.white,
        fontSize: (w * 0.038).clamp(14.0, 15.0),
      ),
      decoration: InputDecoration(
        hintText: 'Search questions...',
        hintStyle: TextStyle(
          color: FaqsTokens.placeholder,
          fontSize: (w * 0.038).clamp(14.0, 15.0),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: FaqsTokens.muted,
          size: (w * 0.055).clamp(22.0, 24.0),
        ),
        filled: true,
        fillColor: FaqsTokens.searchField,
        contentPadding: EdgeInsets.symmetric(
          vertical: (w * 0.035).clamp(14.0, 16.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: FaqsTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: FaqsTokens.accentSolid,
            width: 1.2,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}
