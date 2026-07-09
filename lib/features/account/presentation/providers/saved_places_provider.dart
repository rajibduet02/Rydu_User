import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'saved_places_controller.dart';

import 'saved_places_controller.dart';

final savedPlacesControllerProvider =
    NotifierProvider<SavedPlacesController, SavedPlacesState>(
      SavedPlacesController.new,
    );
