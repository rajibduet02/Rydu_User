import 'package:flutter/material.dart';

import '../providers/report_lost_item_controller.dart';
import '../theme/report_lost_item_tokens.dart';

class ContactPreferenceSelector extends StatelessWidget {
  const ContactPreferenceSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.03).clamp(10.0, 12.0);

    return Container(
      decoration: BoxDecoration(
        color: ReportLostItemTokens.field,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ReportLostItemTokens.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Segment(
            label: 'Phone',
            icon: Icons.phone_outlined,
            value: kContactPreferencePhone,
            isSelected: selected == kContactPreferencePhone,
            onTap: () => onSelected(kContactPreferencePhone),
          ),
          _Segment(
            label: 'Email',
            icon: Icons.mail_outline_rounded,
            value: kContactPreferenceEmail,
            isSelected: selected == kContactPreferenceEmail,
            onTap: () => onSelected(kContactPreferenceEmail),
          ),
          _Segment(
            label: 'Chat',
            icon: Icons.chat_bubble_outline_rounded,
            value: kContactPreferenceChat,
            isSelected: selected == kContactPreferenceChat,
            onTap: () => onSelected(kContactPreferenceChat),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.032).clamp(12.0, 13.0);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular((w * 0.025).clamp(8.0, 10.0)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              vertical: (w * 0.03).clamp(10.0, 12.0),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? ReportLostItemTokens.selectedSegment
                  : Colors.transparent,
              borderRadius: BorderRadius.circular((w * 0.025).clamp(8.0, 10.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: (w * 0.05).clamp(20.0, 22.0),
                  color: isSelected
                      ? ReportLostItemTokens.accentSolid
                      : ReportLostItemTokens.muted,
                ),
                SizedBox(height: (w * 0.01).clamp(4.0, 6.0)),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? ReportLostItemTokens.white
                        : ReportLostItemTokens.muted,
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
