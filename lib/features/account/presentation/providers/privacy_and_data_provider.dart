import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'privacy_and_data_controller.dart';

import 'privacy_and_data_controller.dart';

final privacyAndDataControllerProvider =
    NotifierProvider<PrivacyAndDataController, PrivacyAndDataState>(
      PrivacyAndDataController.new,
    );
