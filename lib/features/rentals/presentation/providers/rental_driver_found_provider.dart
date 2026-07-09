import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rental_driver_found_controller.dart';

final rentalDriverFoundControllerProvider =
    NotifierProvider<RentalDriverFoundController, RentalDriverFoundState>(
      RentalDriverFoundController.new,
    );
