import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'help_center_controller.dart';

final helpCenterControllerProvider =
    NotifierProvider<HelpCenterController, HelpCenterState>(
      HelpCenterController.new,
    );
