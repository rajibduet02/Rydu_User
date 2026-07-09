import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'rentals_controller.dart';

final rentalsControllerProvider =
    NotifierProvider<RentalsController, RentalsState>(RentalsController.new);
