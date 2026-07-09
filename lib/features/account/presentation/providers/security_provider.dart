import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'security_controller.dart';

import 'security_controller.dart';

final securityControllerProvider =
    NotifierProvider<SecurityController, SecurityState>(SecurityController.new);
