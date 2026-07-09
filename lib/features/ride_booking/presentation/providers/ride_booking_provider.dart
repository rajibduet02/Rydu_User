import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'ride_booking_controller.dart';
export 'ride_booking_dependencies.dart';

import 'ride_booking_controller.dart';

final rideBookingControllerProvider =
    NotifierProvider<RideBookingController, RideBookingState>(
      RideBookingController.new,
    );
