import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'payment_method_controller.dart';

import 'payment_method_controller.dart';

final paymentMethodControllerProvider =
    NotifierProvider<PaymentMethodController, PaymentMethodState>(
      PaymentMethodController.new,
    );
