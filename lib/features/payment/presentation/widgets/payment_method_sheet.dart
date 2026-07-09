import 'package:flutter/material.dart';

import 'payment_method_modal.dart';

/// Opens the shared Pay with bottom sheet (React `PaymentMethodModal`).
abstract final class PaymentMethodSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const PaymentMethodModal(),
    );
  }
}
