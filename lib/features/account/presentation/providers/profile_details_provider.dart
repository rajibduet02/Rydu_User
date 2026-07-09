import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'profile_details_controller.dart';

import 'profile_details_controller.dart';

final profileDetailsControllerProvider =
    NotifierProvider<ProfileDetailsController, ProfileDetailsState>(
      ProfileDetailsController.new,
    );
