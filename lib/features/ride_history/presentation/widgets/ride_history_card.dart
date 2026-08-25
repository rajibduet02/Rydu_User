import 'package:flutter/material.dart';

import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../../domain/ride_history_filter.dart';
import '../ride_history_presentation.dart';
import '../theme/ride_history_tokens.dart';

class RideHistoryCard extends StatelessWidget {
  const RideHistoryCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  final BookingEntity booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kind = RideHistoryPresentation.kind(booking.status);
    final chipColor = switch (kind) {
      RideHistoryStatusKind.completed => RideHistoryTokens.success,
      RideHistoryStatusKind.cancelled => RideHistoryTokens.danger,
      RideHistoryStatusKind.expired => RideHistoryTokens.warning,
      RideHistoryStatusKind.other => RideHistoryTokens.muted,
    };
    final timestamp = RideHistoryPresentation.preferredTimestamp(booking);
    final dateLabel = timestamp == null
        ? null
        : RideHistoryPresentation.formatTimestamp(timestamp);
    final service = RideHistoryPresentation.serviceLabel(booking);
    final fare = booking.formattedFare;
    final extra = RideHistoryPresentation.distanceDurationLabel(booking);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: RideHistoryTokens.sheet,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: chipColor.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (dateLabel != null)
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: const TextStyle(
                            color: RideHistoryTokens.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    _StatusChip(
                      label: RideHistoryPresentation.statusLabel(booking.status),
                      color: chipColor,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  RideHistoryPresentation.routeLabel(booking),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RideHistoryTokens.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (service != null)
                      Expanded(
                        child: Text(
                          extra == null ? service : '$service · $extra',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: RideHistoryTokens.muted,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    if (fare != null)
                      Text(
                        fare,
                        style: const TextStyle(
                          color: RideHistoryTokens.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RideHistoryFilterChips extends StatelessWidget {
  const RideHistoryFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final RideHistoryFilter selected;
  final ValueChanged<RideHistoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final filter in RideHistoryFilter.values) ...[
          if (filter != RideHistoryFilter.values.first) const SizedBox(width: 8),
          _FilterChip(
            label: filter.label,
            selected: selected == filter,
            onTap: () => onSelected(filter),
          ),
        ],
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? RideHistoryTokens.white
                : RideHistoryTokens.chipUnselectedBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? RideHistoryTokens.white
                  : RideHistoryTokens.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? RideHistoryTokens.onLight
                  : RideHistoryTokens.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
