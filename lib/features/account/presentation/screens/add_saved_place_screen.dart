import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/saved_places_tokens.dart';

/// Placeholder until add-place map / search flow exists.
class AddSavedPlaceScreen extends StatelessWidget {
  const AddSavedPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SavedPlacesTokens.background,
      appBar: AppBar(
        backgroundColor: SavedPlacesTokens.background,
        foregroundColor: SavedPlacesTokens.white,
        elevation: 0,
        title: const Text('Add saved place'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            // TODO: Open address search / map pin flow when backend and Places API are ready.
            'TODO: Add address search and map picker here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SavedPlacesTokens.muted, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
