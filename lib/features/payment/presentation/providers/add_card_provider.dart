import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_card_controller.dart';

final addCardControllerProvider =
    AutoDisposeNotifierProvider<AddCardController, AddCardState>(
      AddCardController.new,
    );
