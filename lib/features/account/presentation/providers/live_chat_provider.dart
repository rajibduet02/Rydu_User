import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'live_chat_controller.dart';

import 'live_chat_controller.dart';

final liveChatControllerProvider =
    NotifierProvider<LiveChatController, LiveChatState>(LiveChatController.new);
