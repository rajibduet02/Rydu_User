import 'package:flutter/material.dart';

import '../providers/report_ride_issue_controller.dart';
import '../theme/report_ride_issue_tokens.dart';

IconData issueTypeIcon(String type) {
  switch (type) {
    case kIssueTypeDriver:
      return Icons.person_outline_rounded;
    case kIssueTypePayment:
      return Icons.account_balance_wallet_outlined;
    case kIssueTypeRoute:
      return Icons.map_outlined;
    case kIssueTypeSafety:
      return Icons.shield_outlined;
    case kIssueTypeLostItem:
      return Icons.inventory_2_outlined;
    case kIssueTypeOther:
      return Icons.more_horiz_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}

class IssueTypeChip extends StatelessWidget {
  const IssueTypeChip({
    super.key,
    required this.issueType,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String issueType;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.03).clamp(10.0, 12.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? ReportRideIssueTokens.selectedBg
                : ReportRideIssueTokens.field,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isSelected
                  ? ReportRideIssueTokens.selectedBorder
                  : ReportRideIssueTokens.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: (w * 0.03).clamp(10.0, 12.0),
            vertical: (w * 0.035).clamp(12.0, 14.0),
          ),
          child: Row(
            children: [
              Icon(
                issueTypeIcon(issueType),
                color: isSelected
                    ? ReportRideIssueTokens.accentSolid
                    : ReportRideIssueTokens.muted,
                size: (w * 0.05).clamp(20.0, 22.0),
              ),
              SizedBox(width: (w * 0.025).clamp(8.0, 10.0)),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ReportRideIssueTokens.white,
                    fontWeight: FontWeight.w600,
                    fontSize: (w * 0.035).clamp(13.0, 14.0),
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
