import 'package:flutter/material.dart';

import '../theme/invite_teen_tokens.dart';

class InviteTeenTextField extends StatelessWidget {
  const InviteTeenTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? hintText;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.038).clamp(14.0, 15.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: InviteTeenTokens.white,
            fontWeight: FontWeight.w600,
            fontSize: labelSize,
          ),
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: focusNode,
          builder: (context, _) {
            final focused = focusNode.hasFocus;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              onTap: onTap,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                color: InviteTeenTokens.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: hintText ?? label,
                hintStyle: const TextStyle(color: InviteTeenTokens.muted),
                filled: true,
                fillColor: InviteTeenTokens.field,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: suffixIcon,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: focused
                        ? InviteTeenTokens.fieldBorder
                        : InviteTeenTokens.fieldBorderMuted,
                    width: focused ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: InviteTeenTokens.fieldBorder,
                    width: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
