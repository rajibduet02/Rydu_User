import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/auth_screen_tokens.dart';

/// Phone number block: label, country code selector, numeric input.
class PhoneInputCard extends StatelessWidget {
  const PhoneInputCard({
    super.key,
    required this.phoneController,
    required this.countryCode,
    required this.onCountryChanged,
    this.errorText,
  });

  final TextEditingController phoneController;
  final String countryCode;
  final ValueChanged<String> onCountryChanged;
  final String? errorText;

  static const _codes = ['+880', '+1', '+44', '+91'];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.035).clamp(12.0, 14.0);
    final fieldFont = (w * 0.04).clamp(15.0, 16.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuthScreenTokens.card,
        borderRadius: BorderRadius.circular(AuthScreenTokens.radiusCard),
        border: Border.all(color: AuthScreenTokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number',
              style: TextStyle(
                color: AuthScreenTokens.muted,
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: (w * 0.24).clamp(88.0, 100.0),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey<String>(countryCode),
                    initialValue: _codes.contains(countryCode)
                        ? countryCode
                        : _codes.first,
                    dropdownColor: AuthScreenTokens.field,
                    style: TextStyle(
                      color: AuthScreenTokens.white,
                      fontSize: fieldFont,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AuthScreenTokens.field,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuthScreenTokens.radiusField,
                        ),
                        borderSide: const BorderSide(
                          color: AuthScreenTokens.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuthScreenTokens.radiusField,
                        ),
                        borderSide: const BorderSide(
                          color: AuthScreenTokens.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuthScreenTokens.radiusField,
                        ),
                        borderSide: const BorderSide(
                          color: AuthScreenTokens.accent,
                          width: 2,
                        ),
                      ),
                    ),
                    items: _codes
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onCountryChanged(v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    style: TextStyle(
                      color: AuthScreenTokens.white,
                      fontSize: fieldFont,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      hintStyle: TextStyle(
                        color: AuthScreenTokens.muted.withValues(alpha: 0.5),
                        fontSize: fieldFont,
                      ),
                      filled: true,
                      fillColor: AuthScreenTokens.field,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuthScreenTokens.radiusField,
                        ),
                        borderSide: const BorderSide(
                          color: AuthScreenTokens.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuthScreenTokens.radiusField,
                        ),
                        borderSide: const BorderSide(
                          color: AuthScreenTokens.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AuthScreenTokens.radiusField,
                        ),
                        borderSide: const BorderSide(
                          color: AuthScreenTokens.accent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
