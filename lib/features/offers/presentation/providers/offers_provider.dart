import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'offers_controller.dart';

import 'offers_controller.dart';

final offersControllerProvider =
    NotifierProvider<OffersController, OffersState>(OffersController.new);
