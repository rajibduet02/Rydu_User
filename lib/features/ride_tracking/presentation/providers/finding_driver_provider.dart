import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'finding_driver_controller.dart';

import 'finding_driver_controller.dart';

final findingDriverControllerProvider =
    NotifierProvider<FindingDriverController, FindingDriverState>(
      FindingDriverController.new,
    );
