import 'package:flutter/material.dart';

import '../providers/email_support_controller.dart';
import '../theme/email_support_tokens.dart';

class EmailSupportDropdown extends StatelessWidget {
  const EmailSupportDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = kEmailSupportCategories,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.028).clamp(10.0, 11.0);
    final fieldSize = (w * 0.038).clamp(14.0, 15.0);
    final radius = (w * 0.03).clamp(10.0, 12.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CATEGORY',
          style: TextStyle(
            color: EmailSupportTokens.label,
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        SizedBox(height: (w * 0.02).clamp(8.0, 10.0)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.04).clamp(14.0, 16.0),
          ),
          decoration: BoxDecoration(
            color: EmailSupportTokens.field,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: EmailSupportTokens.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              isExpanded: true,
              dropdownColor: EmailSupportTokens.card,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: EmailSupportTokens.muted,
                size: (w * 0.065).clamp(24.0, 28.0),
              ),
              style: TextStyle(
                color: EmailSupportTokens.white,
                fontSize: fieldSize,
                fontWeight: FontWeight.w500,
              ),
              items: options
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
