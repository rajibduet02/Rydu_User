import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'family_profile_controller.dart';

import 'family_profile_controller.dart';

final familyProfileControllerProvider =
    NotifierProvider<FamilyProfileController, FamilyProfileState>(
      FamilyProfileController.new,
    );
