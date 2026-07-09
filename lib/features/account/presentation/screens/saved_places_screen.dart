import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../models/saved_place.dart';
import '../providers/saved_places_provider.dart';
import '../theme/saved_places_tokens.dart';
import '../widgets/add_new_place_card.dart';
import '../widgets/recent_place_card.dart';
import '../widgets/saved_place_card.dart';

class SavedPlacesScreen extends ConsumerStatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  ConsumerState<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends ConsumerState<SavedPlacesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(savedPlacesControllerProvider.notifier).loadSavedPlaces();
    });
  }

  void _popOrAccount(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  Future<void> _confirmDelete(BuildContext context, String placeId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SavedPlacesTokens.cardTop,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: SavedPlacesTokens.border),
          ),
          title: const Text(
            'Delete place',
            style: TextStyle(
              color: SavedPlacesTokens.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Remove this saved place?',
            style: TextStyle(color: SavedPlacesTokens.muted, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (!mounted || ok != true) return;
    ref.read(savedPlacesControllerProvider.notifier).deletePlace(placeId);
  }

  void _showPlaceMenu(BuildContext context, SavedPlace place) {
    final c = ref.read(savedPlacesControllerProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SavedPlacesTokens.cardTop,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit_outlined,
                  color: SavedPlacesTokens.white,
                ),
                title: const Text(
                  'Edit',
                  style: TextStyle(color: SavedPlacesTokens.white),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  c.editPlace(place.id);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _confirmDelete(context, place.id);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.star_outline_rounded,
                  color: SavedPlacesTokens.accent,
                ),
                title: const Text(
                  'Set as default',
                  style: TextStyle(color: SavedPlacesTokens.white),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  c.setDefaultPlace(place.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(savedPlacesControllerProvider);
    final c = ref.read(savedPlacesControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.055).clamp(18.0, 24.0);
    final sectionGap = (w * 0.055).clamp(20.0, 26.0);
    final cardGap = (w * 0.03).clamp(10.0, 12.0);
    final titleSize = (w * 0.065).clamp(22.0, 26.0);
    final subtitleSize = (w * 0.037).clamp(13.0, 15.0);
    final sectionTitleSize = (w * 0.045).clamp(16.0, 18.0);

    return Scaffold(
      backgroundColor: SavedPlacesTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: SavedPlacesTokens.cardTop,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _popOrAccount(context),
                      child: Padding(
                        padding: EdgeInsets.all((w * 0.028).clamp(10.0, 12.0)),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: SavedPlacesTokens.white,
                          size: (w * 0.07).clamp(26.0, 30.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: (w * 0.035).clamp(12.0, 14.0)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Places',
                          style: TextStyle(
                            color: SavedPlacesTokens.white,
                            fontWeight: FontWeight.w800,
                            fontSize: titleSize,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: (w * 0.018).clamp(6.0, 8.0)),
                        Text(
                          'Quick access to your favorite locations',
                          style: TextStyle(
                            color: SavedPlacesTokens.muted,
                            fontSize: subtitleSize,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: (w * 0.04).clamp(14.0, 18.0)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: const Divider(
                height: 1,
                thickness: 1,
                color: SavedPlacesTokens.border,
              ),
            ),
            if (s.errorMessage != null) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                child: Text(
                  s.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(hPad, sectionGap, hPad, 32),
                children: [
                  Text(
                    'Your Places',
                    style: TextStyle(
                      color: SavedPlacesTokens.white,
                      fontWeight: FontWeight.w800,
                      fontSize: sectionTitleSize,
                    ),
                  ),
                  SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
                  ...s.savedPlaces.expand(
                    (p) => [
                      SavedPlaceCard(
                        place: p,
                        onTap: () => c.openSavedPlace(p.id),
                        onMenuTap: () => _showPlaceMenu(context, p),
                      ),
                      SizedBox(height: cardGap),
                    ],
                  ),
                  AddNewPlaceCard(onTap: c.addNewPlace),
                  SizedBox(height: sectionGap + 4),
                  Text(
                    'Recent',
                    style: TextStyle(
                      color: SavedPlacesTokens.white,
                      fontWeight: FontWeight.w800,
                      fontSize: sectionTitleSize,
                    ),
                  ),
                  SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
                  ...s.recentPlaces.expand(
                    (p) => [
                      RecentPlaceCard(
                        place: p,
                        onTap: () => c.selectRecentPlace(p.id),
                      ),
                      SizedBox(height: cardGap),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
