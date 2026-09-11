import '../../../../core/payments/rydu_payments.dart';
import 'ride_planning_entities.dart';

class PaymentConfigEntity {
  const PaymentConfigEntity({
    required this.stripeEnabled,
    required this.cardEnabled,
    this.publishableKey,
  });

  final bool stripeEnabled;
  final bool cardEnabled;
  final String? publishableKey;

  bool get canInitializeStripe {
    final key = publishableKey?.trim() ?? '';
    return cardEnabled && key.startsWith('pk_');
  }
}

class BookingPaymentEntity {
  const BookingPaymentEntity({
    required this.paymentMethod,
    required this.status,
    this.paymentIntentId,
    this.amount,
    this.currency,
    this.clientSecret,
  });

  final String paymentMethod;
  final String status;
  final String? paymentIntentId;
  final int? amount;
  final String? currency;
  final String? clientSecret;

  String get normalizedStatus => status.trim().toLowerCase();

  String get normalizedMethod => paymentMethod.trim().toLowerCase();

  bool get isCard => isCardPaymentMethodCode(normalizedMethod);

  bool get isAuthorized => normalizedStatus == 'authorized';

  bool get isFailed => normalizedStatus == 'failed';

  bool get isCancelled =>
      normalizedStatus == 'cancelled' || normalizedStatus == 'canceled';

  bool get requiresAction => normalizedStatus == 'requires_action';

  bool get needsPayment {
    switch (normalizedStatus) {
      case 'pending':
      case 'requires_payment_method':
      case 'requires_action':
        return true;
      default:
        return false;
    }
  }

  bool get hasClientSecret {
    final secret = clientSecret?.trim() ?? '';
    return secret.isNotEmpty;
  }

  bool get isTerminal => isAuthorized || isFailed || isCancelled;
}

class CreateBookingResult {
  const CreateBookingResult({required this.booking, this.payment});

  final BookingEntity booking;
  final BookingPaymentEntity? payment;
}

enum CardPaymentUiState {
  idle,
  preparing,
  presentingSheet,
  authorizing,
  failed,
  requiresAction,
  authorized,
}

bool isCardPaymentMethodCode(String? code) {
  final value = (code ?? '').trim().toLowerCase();
  return value == 'card';
}

bool isCashPaymentMethodCode(String? code) {
  final value = (code ?? '').trim().toLowerCase();
  return value == 'cash' || value.isEmpty;
}

bool isCashPaymentLabel(String? label) {
  return (label ?? '').trim().toLowerCase() == 'cash';
}

/// Passenger booking is Card-only. Cash is never shown or sent.
abstract final class CardBookingPayment {
  static const code = 'card';
  static const label = 'Card';
  static const unavailableMessage = RyduPayments.cardUnavailableMessage;

  static const method = PaymentMethodEntity(
    code: code,
    label: label,
    isDefault: true,
  );

  static List<PaymentMethodEntity> visibleForBooking(
    List<PaymentMethodEntity> backend,
  ) {
    for (final item in backend) {
      if (isCardPaymentMethodCode(item.code)) {
        final text = item.label.trim().isEmpty ? label : item.label;
        return [
          PaymentMethodEntity(code: item.code, label: text, isDefault: true),
        ];
      }
    }
    return const [method];
  }

  static bool backendIncludesCard(List<PaymentMethodEntity> methods) {
    return methods.any((m) => isCardPaymentMethodCode(m.code));
  }
}
