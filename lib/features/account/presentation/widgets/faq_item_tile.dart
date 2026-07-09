import 'package:flutter/material.dart';

import '../models/faq_item.dart';
import '../theme/faqs_tokens.dart';

class FaqItemTile extends StatelessWidget {
  const FaqItemTile({
    super.key,
    required this.faq,
    required this.isExpanded,
    required this.onTap,
    this.onNeedHelpTap,
  });

  final FaqItem faq;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback? onNeedHelpTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.035).clamp(12.0, 14.0);
    final categorySize = (w * 0.028).clamp(10.0, 11.0);
    final questionSize = (w * 0.042).clamp(15.0, 16.0);
    final answerSize = (w * 0.035).clamp(13.0, 14.0);

    return Container(
      margin: EdgeInsets.only(bottom: (w * 0.03).clamp(10.0, 12.0)),
      decoration: BoxDecoration(
        color: FaqsTokens.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: FaqsTokens.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isExpanded)
                Container(width: 3, color: FaqsTokens.expandAccent),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: EdgeInsets.all((w * 0.045).clamp(16.0, 18.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      faq.category.toUpperCase(),
                                      style: TextStyle(
                                        color: FaqsTokens.categoryLabel,
                                        fontSize: categorySize,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    SizedBox(
                                      height: (w * 0.015).clamp(6.0, 8.0),
                                    ),
                                    Text(
                                      faq.question,
                                      style: TextStyle(
                                        color: FaqsTokens.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: questionSize,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: FaqsTokens.muted,
                                size: (w * 0.065).clamp(24.0, 28.0),
                              ),
                            ],
                          ),
                          if (isExpanded) ...[
                            SizedBox(height: (w * 0.035).clamp(12.0, 14.0)),
                            Text(
                              faq.answer,
                              style: TextStyle(
                                color: FaqsTokens.muted,
                                fontSize: answerSize,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: (w * 0.04).clamp(14.0, 16.0)),
                            _NeedMoreHelpCard(onTap: onNeedHelpTap),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeedMoreHelpCard extends StatelessWidget {
  const _NeedMoreHelpCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all((w * 0.035).clamp(12.0, 14.0)),
          decoration: BoxDecoration(
            color: FaqsTokens.cardDeep,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: FaqsTokens.border),
          ),
          child: Row(
            children: [
              Container(
                width: (w * 0.1).clamp(38.0, 42.0),
                height: (w * 0.1).clamp(38.0, 42.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: FaqsTokens.iconWell,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.headset_mic_outlined,
                  color: FaqsTokens.accentSolid,
                  size: (w * 0.05).clamp(20.0, 22.0),
                ),
              ),
              SizedBox(width: (w * 0.03).clamp(10.0, 12.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need more help?',
                      style: TextStyle(
                        color: FaqsTokens.white,
                        fontWeight: FontWeight.w700,
                        fontSize: (w * 0.038).clamp(14.0, 15.0),
                      ),
                    ),
                    Text(
                      'Live chat available 24/7',
                      style: TextStyle(
                        color: FaqsTokens.muted,
                        fontSize: (w * 0.032).clamp(12.0, 13.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
