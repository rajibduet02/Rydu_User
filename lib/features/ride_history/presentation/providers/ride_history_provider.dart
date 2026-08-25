import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ride_history_controller.dart';

export 'ride_history_controller.dart';
export 'ride_history_dependencies.dart';

final rideHistoryControllerProvider =
    NotifierProvider<RideHistoryController, RideHistoryState>(
      RideHistoryController.new,
    );
