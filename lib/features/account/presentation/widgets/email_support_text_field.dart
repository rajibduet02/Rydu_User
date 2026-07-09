import 'package:flutter/material.dart';

import '../theme/email_support_tokens.dart';

class EmailSupportTextField extends StatelessWidget {
  const EmailSupportTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.028).clamp(10.0, 11.0);
    final fieldSize = (w * 0.038).clamp(14.0, 15.0);
    final radius = (w * 0.03).clamp(10.0, 12.0);
    final vPad = maxLines > 1 ? (w * 0.03).clamp(12.0, 14.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: EmailSupportTokens.label,
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          minLines: minLines,
          style: TextStyle(
            color: EmailSupportTokens.white,
            fontSize: fieldSize,
            height: maxLines > 1 ? 1.45 : 1.2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: EmailSupportTokens.placeholder,
              fontSize: fieldSize,
            ),
            filled: true,
            fillColor: EmailSupportTokens.field,
            contentPadding: EdgeInsets.symmetric(
              horizontal: (w * 0.04).clamp(14.0, 16.0),
              vertical: vPad > 0 ? vPad : (w * 0.035).clamp(14.0, 16.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: EmailSupportTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(
                color: EmailSupportTokens.accent,
                width: 1.2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
      ],
    );
  }
}
