import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reserve_controller.dart';

final reserveControllerProvider =
    NotifierProvider<ReserveController, ReserveState>(ReserveController.new);
