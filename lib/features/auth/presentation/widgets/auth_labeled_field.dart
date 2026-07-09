import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/auth_field_palette.dart';
import '../theme/auth_screen_tokens.dart';

/// Single labeled input used on login and registration screens.
class AuthLabeledField extends StatelessWidget {
  const AuthLabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.palette = AuthFieldPalette.dark,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final AuthFieldPalette palette;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.035).clamp(12.0, 14.0);
    final fieldSize = (w * 0.04).clamp(15.0, 16.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.formSurface,
        borderRadius: BorderRadius.circular(AuthScreenTokens.radiusCard),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: palette.labelColor,
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              inputFormatters: inputFormatters,
              textCapitalization: textCapitalization,
              style: TextStyle(color: palette.textColor, fontSize: fieldSize),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: palette.hintColor,
                  fontSize: fieldSize,
                ),
                filled: true,
                fillColor: palette.inputSurface,
                suffixIcon: suffixIcon,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AuthScreenTokens.radiusField,
                  ),
                  borderSide: BorderSide(color: palette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AuthScreenTokens.radiusField,
                  ),
                  borderSide: BorderSide(color: palette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AuthScreenTokens.radiusField,
                  ),
                  borderSide: BorderSide(
                    color: palette.focusedBorder,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
