import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/family_add_member_tokens.dart';

class GuardianPhoneField extends StatelessWidget {
  const GuardianPhoneField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.countryCode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String countryCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.038).clamp(14.0, 15.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: TextStyle(
            color: FamilyAddMemberTokens.white,
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
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
              style: const TextStyle(
                color: FamilyAddMemberTokens.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: '01812-345678',
                hintStyle: const TextStyle(color: FamilyAddMemberTokens.muted),
                filled: true,
                fillColor: FamilyAddMemberTokens.field,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🇧🇩', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        countryCode,
                        style: const TextStyle(
                          color: FamilyAddMemberTokens.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        margin: const EdgeInsets.only(left: 10),
                        color: FamilyAddMemberTokens.fieldBorderMuted,
                      ),
                    ],
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: focused
                        ? FamilyAddMemberTokens.fieldBorder
                        : FamilyAddMemberTokens.fieldBorderMuted,
                    width: focused ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: FamilyAddMemberTokens.fieldBorder,
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
