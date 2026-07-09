import 'package:flutter/material.dart';

import '../theme/terms_screen_tokens.dart';

/// “I Agree” label with circular checkbox on the right.
class TermsAgreementRow extends StatelessWidget {
  const TermsAgreementRow({
    super.key,
    required this.isSelected,
    required this.onTap,
    this.labelFontSize = 17,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    final box = (MediaQuery.sizeOf(context).width * 0.07).clamp(26.0, 30.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'I Agree',
                  style: TextStyle(
                    color: TermsScreenTokens.title,
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: box,
                height: box,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? TermsScreenTokens.link
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? TermsScreenTokens.link
                        : TermsScreenTokens.borderMuted,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: TermsScreenTokens.link.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: TermsScreenTokens.title,
                        size: box * 0.55,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
