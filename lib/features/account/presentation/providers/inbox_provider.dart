import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inbox_controller.dart';

final inboxControllerProvider = NotifierProvider<InboxController, InboxState>(
  InboxController.new,
);
