import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rental_ride_selection_controller.dart';

final rentalRideSelectionControllerProvider =
    NotifierProvider<RentalRideSelectionController, RentalRideSelectionState>(
      RentalRideSelectionController.new,
    );
