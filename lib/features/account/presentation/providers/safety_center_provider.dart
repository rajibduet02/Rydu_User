import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'safety_center_controller.dart';

final safetyCenterControllerProvider =
    NotifierProvider<SafetyCenterController, SafetyCenterState>(
      SafetyCenterController.new,
    );
