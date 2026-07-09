import 'package:flutter/material.dart';

import '../theme/rental_time_tokens.dart';

class RentalTimeSelector extends StatelessWidget {
  const RentalTimeSelector({
    super.key,
    required this.hours,
    required this.includedKm,
    required this.minHours,
    required this.maxHours,
    required this.onDecrease,
    required this.onIncrease,
    required this.onSliderChanged,
  });

  final int hours;
  final int includedKm;
  final int minHours;
  final int maxHours;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<double> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final numSize = (w * 0.18).clamp(56.0, 72.0);
    final hourWordSize = (w * 0.14).clamp(44.0, 56.0);
    final subSize = (w * 0.04).clamp(15.0, 16.0);
    final canDec = hours > minHours;
    final canInc = hours < maxHours;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CircleIconButton(
              icon: Icons.remove,
              enabled: canDec,
              onTap: onDecrease,
            ),
            SizedBox(width: (w * 0.04).clamp(12.0, 20.0)),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$hours',
                    style: TextStyle(
                      color: RentalTimeTokens.white,
                      fontSize: numSize,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    hours == 1 ? 'hour' : 'hours',
                    style: TextStyle(
                      color: RentalTimeTokens.white,
                      fontSize: hourWordSize,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: (w * 0.02).clamp(6.0, 10.0)),
                  Text(
                    '$includedKm km included',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: RentalTimeTokens.subtitleBlue,
                      fontSize: subSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: (w * 0.04).clamp(12.0, 20.0)),
            _CircleIconButton(
              icon: Icons.add,
              enabled: canInc,
              onTap: onIncrease,
            ),
          ],
        ),
        SizedBox(height: (w * 0.05).clamp(18.0, 24.0)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: (w * 0.02).clamp(4.0, 8.0)),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: RentalTimeTokens.sliderActive,
              inactiveTrackColor: RentalTimeTokens.sliderTrack,
              thumbColor: RentalTimeTokens.thumb,
              overlayColor: RentalTimeTokens.white.withValues(alpha: 0.12),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: hours.toDouble(),
              min: minHours.toDouble(),
              max: maxHours.toDouble(),
              divisions: maxHours - minHours,
              onChanged: onSliderChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Ink(
          width: RentalTimeTokens.stepButtonSize,
          height: RentalTimeTokens.stepButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: RentalTimeTokens.iconWell,
            border: Border.all(color: RentalTimeTokens.border),
          ),
          child: Icon(
            icon,
            color: icon == Icons.remove
                ? RentalTimeTokens.muted.withValues(alpha: enabled ? 1 : 0.35)
                : RentalTimeTokens.white.withValues(alpha: enabled ? 1 : 0.35),
            size: 28,
          ),
        ),
      ),
    );
  }
}
