import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../models/saved_place.dart';
import '../theme/saved_places_tokens.dart';

/// Placeholder until full saved-place detail / map preview exists.
class SavedPlaceDetailScreen extends StatelessWidget {
  const SavedPlaceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final place = extra is SavedPlace ? extra : null;

    return Scaffold(
      backgroundColor: SavedPlacesTokens.background,
      appBar: AppBar(
        backgroundColor: SavedPlacesTokens.background,
        foregroundColor: SavedPlacesTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.savedPlaces);
            }
          },
        ),
        title: Text(place?.title ?? 'Saved place'),
      ),
      body: place == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No place selected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: SavedPlacesTokens.muted,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    place.address,
                    style: const TextStyle(
                      color: SavedPlacesTokens.muted,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  if (place.isDefault) ...[
                    const SizedBox(height: 16),
                    Chip(
                      label: const Text('Default'),
                      backgroundColor: SavedPlacesTokens.cardTop,
                      labelStyle: const TextStyle(
                        color: SavedPlacesTokens.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    // TODO: Show map preview, ride shortcuts, and edit when wired to maps SDK.
                    'TODO: Integrate map preview and ride-from-saved-place actions.',
                    style: TextStyle(
                      color: SavedPlacesTokens.muted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
