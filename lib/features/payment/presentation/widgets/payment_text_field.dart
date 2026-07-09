import 'package:flutter/material.dart';

import '../theme/add_card_tokens.dart';

class PaymentTextField extends StatelessWidget {
  const PaymentTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.035).clamp(13.0, 14.0);
    final inputSize = (w * 0.045).clamp(16.0, 18.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AddCardTokens.muted,
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          style: TextStyle(
            color: AddCardTokens.white,
            fontSize: inputSize,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AddCardTokens.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AddCardTokens.muted.withValues(alpha: 0.4),
              fontSize: inputSize,
            ),
            filled: true,
            fillColor: AddCardTokens.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AddCardTokens.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AddCardTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AddCardTokens.accent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
