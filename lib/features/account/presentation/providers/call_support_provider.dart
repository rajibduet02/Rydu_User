import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'call_support_controller.dart';

import 'call_support_controller.dart';

final callSupportControllerProvider =
    NotifierProvider<CallSupportController, CallSupportState>(
      CallSupportController.new,
    );
