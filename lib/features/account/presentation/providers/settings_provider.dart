import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_controller.dart';

export 'settings_controller.dart';

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
