import 'package:flutter/material.dart';

import '../models/saved_place.dart';
import '../theme/saved_places_tokens.dart';

class _PlaceColors {
  const _PlaceColors({required this.well, required this.icon});

  final Color well;
  final Color icon;
}

_PlaceColors _colorsFor(String colorType) {
  switch (colorType) {
    case 'blue':
      return const _PlaceColors(
        well: Color(0xFF1A2F55),
        icon: Color(0xFF2F6BFF),
      );
    case 'orange':
      return const _PlaceColors(
        well: Color(0xFF3D2810),
        icon: Color(0xFFFF9F45),
      );
    case 'pink':
      return const _PlaceColors(
        well: Color(0xFF3A1F35),
        icon: Color(0xFFFF6BB3),
      );
    case 'green':
      return const _PlaceColors(
        well: Color(0xFF14332A),
        icon: Color(0xFF3DDC97),
      );
    default:
      return const _PlaceColors(
        well: SavedPlacesTokens.iconWell,
        icon: SavedPlacesTokens.muted,
      );
  }
}

IconData _iconFor(String iconType) {
  switch (iconType) {
    case 'home':
      return Icons.home_rounded;
    case 'work':
      return Icons.work_outline_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'pin':
      return Icons.location_on_rounded;
    default:
      return Icons.place_rounded;
  }
}

class SavedPlaceCard extends StatelessWidget {
  const SavedPlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.onMenuTap,
  });

  final SavedPlace place;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final hPad = (w * 0.04).clamp(14.0, 16.0);
    final vPad = (w * 0.035).clamp(14.0, 16.0);
    final iconSize = (w * 0.1).clamp(40.0, 48.0);
    final c = _colorsFor(place.colorType);

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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.well,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _iconFor(place.iconType),
                  color: c.icon,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SavedPlacesTokens.white,
                        fontWeight: FontWeight.w700,
                        fontSize: (w * 0.042).clamp(15.0, 17.0),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: (w * 0.012).clamp(4.0, 6.0)),
                    Text(
                      place.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SavedPlacesTokens.muted,
                        fontSize: (w * 0.035).clamp(12.5, 14.0),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onMenuTap,
                style: IconButton.styleFrom(
                  foregroundColor: SavedPlacesTokens.muted,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size((w * 0.09).clamp(36.0, 40.0), 40),
                  padding: EdgeInsets.zero,
                ),
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: (w * 0.055).clamp(22.0, 24.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
