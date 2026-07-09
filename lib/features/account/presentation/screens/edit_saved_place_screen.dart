import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/saved_place.dart';
import '../theme/saved_places_tokens.dart';

/// Placeholder until edit form is implemented.
class EditSavedPlaceScreen extends StatelessWidget {
  const EditSavedPlaceScreen({super.key});

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
        title: Text(place == null ? 'Edit place' : 'Edit ${place.title}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            place == null
                ? 'No place to edit.'
                // TODO: Load place draft from API and save changes.
                : 'TODO: Edit fields for "${place.title}" and persist via API.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: SavedPlacesTokens.muted,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
