import 'package:flutter/material.dart';

import '../models/recent_place.dart';
import '../theme/saved_places_tokens.dart';

class RecentPlaceCard extends StatelessWidget {
  const RecentPlaceCard({super.key, required this.place, required this.onTap});

  final RecentPlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final hPad = (w * 0.04).clamp(14.0, 16.0);
    final vPad = (w * 0.035).clamp(14.0, 16.0);
    final iconSize = (w * 0.1).clamp(40.0, 48.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [SavedPlacesTokens.cardTop, SavedPlacesTokens.cardBottom],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: SavedPlacesTokens.border),
          ),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SavedPlacesTokens.iconWell,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.schedule_rounded,
                  color: SavedPlacesTokens.muted,
                  size: iconSize * 0.48,
                ),
              ),
              SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SavedPlacesTokens.white,
                        fontWeight: FontWeight.w700,
                        fontSize: (w * 0.042).clamp(15.0, 17.0),
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: (w * 0.012).clamp(4.0, 6.0)),
                    Text(
                      place.timeAgo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SavedPlacesTokens.muted,
                        fontSize: (w * 0.035).clamp(12.5, 14.0),
                        height: 1.2,
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
