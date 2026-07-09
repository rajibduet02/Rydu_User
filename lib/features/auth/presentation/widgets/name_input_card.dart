import 'package:flutter/material.dart';

import '../theme/name_input_tokens.dart';

/// Rounded outer card with label and pill-shaped inner text field.
class NameInputCard extends StatelessWidget {
  const NameInputCard({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.focusNode,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? errorText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.035).clamp(12.0, 14.0);
    final fieldSize = (w * 0.04).clamp(15.0, 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: NameInputTokens.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: NameInputTokens.border.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
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
                    color: NameInputTokens.muted,
                    fontSize: labelSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  focusNode: focusNode,
                  controller: controller,
                  textInputAction: textInputAction,
                  onSubmitted: onSubmitted,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    color: NameInputTokens.white,
                    fontSize: fieldSize,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: NameInputTokens.muted.withValues(alpha: 0.5),
                      fontSize: fieldSize,
                    ),
                    filled: true,
                    fillColor: NameInputTokens.fieldFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(
                        color: NameInputTokens.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(
                        color: NameInputTokens.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(
                        color: NameInputTokens.borderFocused,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
