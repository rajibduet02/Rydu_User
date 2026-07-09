import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rental_time_controller.dart';

final rentalTimeControllerProvider =
    NotifierProvider<RentalTimeController, RentalTimeState>(
      RentalTimeController.new,
    );
