/// Central passenger payment display constants.
///
/// Do not put Stripe keys here. Publishable keys come from GET /config/payments.
abstract final class RyduPayments {
  static const merchantDisplayName = 'Rydu';
  static const cardUnavailableMessage =
      'Card payment is currently unavailable. Please try again later.';
}
