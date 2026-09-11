import '../../domain/entities/booking_payment_entities.dart';

/// Bounded poll schedule after PaymentSheet success.
abstract final class PaymentAuthorizationPoller {
  static const timeout = Duration(seconds: 25);

  static const intervals = <Duration>[
    Duration.zero,
    Duration(milliseconds: 800),
    Duration(milliseconds: 1500),
    Duration(seconds: 2),
    Duration(seconds: 2),
    Duration(seconds: 2),
    Duration(seconds: 3),
    Duration(seconds: 3),
    Duration(seconds: 4),
  ];

  static bool isTerminal(BookingPaymentEntity payment) => payment.isTerminal;
}
