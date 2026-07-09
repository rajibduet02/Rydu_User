import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'safety_resources_controller.dart';

import 'safety_resources_controller.dart';

final safetyResourcesControllerProvider =
    NotifierProvider<SafetyResourcesController, SafetyResourcesState>(
      SafetyResourcesController.new,
    );
