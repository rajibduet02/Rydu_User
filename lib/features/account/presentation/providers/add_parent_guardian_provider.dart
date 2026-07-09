import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'add_parent_guardian_controller.dart';

import 'add_parent_guardian_controller.dart';

final addParentGuardianControllerProvider =
    NotifierProvider<AddParentGuardianController, AddParentGuardianState>(
      AddParentGuardianController.new,
    );
