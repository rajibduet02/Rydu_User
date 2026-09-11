import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../../core/payments/stripe_debug.dart';

enum StripeSheetOutcome { completed, canceled, failed }

/// Isolates the official Stripe SDK so booking flow and tests can swap it.
abstract interface class StripePaymentGateway {
  Future<bool> initialize({required String publishableKey});

  Future<StripeSheetOutcome> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  });
}

class FlutterStripePaymentGateway implements StripePaymentGateway {
  String? _initializedPublishableKey;

  @override
  Future<bool> initialize({required String publishableKey}) async {
    final key = publishableKey.trim();
    StripeDebug.log('Stripe initialization starting');
    StripeDebug.log('publishableKeyMode=${StripeDebug.publishableKeyMode(key)}');
    if (!key.startsWith('pk_')) {
      StripeDebug.log('Stripe initialization FAILED');
      StripeDebug.log('errorType=invalid_publishable_key');
      StripeDebug.log('error=publishable key missing pk_ prefix');
      return false;
    }
    if (_initializedPublishableKey == key) {
      StripeDebug.log('Stripe initialization SUCCESS');
      return true;
    }
    try {
      Stripe.publishableKey = key;
      StripeDebug.log('Stripe.applySettings starting');
      await Stripe.instance.applySettings();
      _initializedPublishableKey = key;
      StripeDebug.log('Stripe initialization SUCCESS');
      return true;
    } catch (e) {
      StripeDebug.log('Stripe initialization FAILED');
      StripeDebug.log('errorType=${e.runtimeType}');
      StripeDebug.log('error=${StripeDebug.redactSecretsInText(e.toString())}');
      return false;
    }
  }

  @override
  Future<StripeSheetOutcome> presentPaymentSheet({
    required String clientSecret,
    required String merchantDisplayName,
  }) async {
    final secret = clientSecret.trim();
    StripeDebug.log('PaymentSheet init starting');
    StripeDebug.log('clientSecretPresent=${secret.isNotEmpty}');
    if (secret.isEmpty) {
      StripeDebug.log('PaymentSheet failed');
      StripeDebug.log('errorCode=missing_client_secret');
      StripeDebug.log('errorMessage=clientSecret missing');
      return StripeSheetOutcome.failed;
    }
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: secret,
          merchantDisplayName: merchantDisplayName,
        ),
      );
      StripeDebug.log('PaymentSheet init SUCCESS');
      StripeDebug.log('PaymentSheet presenting');
      await Stripe.instance.presentPaymentSheet();
      StripeDebug.log('PaymentSheet completed');
      return StripeSheetOutcome.completed;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        StripeDebug.log('PaymentSheet cancelled');
        return StripeSheetOutcome.canceled;
      }
      StripeDebug.log('PaymentSheet failed');
      StripeDebug.log('errorCode=${e.error.code}');
      StripeDebug.log(
        'errorMessage=${StripeDebug.redactSecretsInText(e.error.message ?? '')}',
      );
      return StripeSheetOutcome.failed;
    } catch (e) {
      StripeDebug.log('PaymentSheet failed');
      StripeDebug.log('errorCode=${e.runtimeType}');
      StripeDebug.log('errorMessage=${StripeDebug.redactSecretsInText(e.toString())}');
      return StripeSheetOutcome.failed;
    }
  }
}
