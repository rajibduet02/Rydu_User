import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'invite_teen_controller.dart';

import 'invite_teen_controller.dart';

final inviteTeenControllerProvider =
    NotifierProvider<InviteTeenController, InviteTeenState>(
      InviteTeenController.new,
    );
