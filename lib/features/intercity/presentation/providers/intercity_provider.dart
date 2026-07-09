import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'intercity_controller.dart';

final intercityControllerProvider =
    NotifierProvider<IntercityController, IntercityState>(
      IntercityController.new,
    );
