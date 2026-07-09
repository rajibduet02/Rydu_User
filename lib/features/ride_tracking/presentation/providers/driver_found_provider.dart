import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'driver_found_controller.dart';

import 'driver_found_controller.dart';

final driverFoundControllerProvider =
    NotifierProvider<DriverFoundController, DriverFoundState>(
      DriverFoundController.new,
    );
