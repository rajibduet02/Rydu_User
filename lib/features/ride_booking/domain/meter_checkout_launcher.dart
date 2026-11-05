import 'package:url_launcher/url_launcher.dart';

import 'entities/meter_payment_entities.dart';

/// Opens a backend-provided Stripe Checkout URL. Never constructs URLs.
abstract class MeterCheckoutLauncher {
  Future<bool> openHostedCheckout(Uri uri);
}

class UrlLauncherMeterCheckoutLauncher implements MeterCheckoutLauncher {
  const UrlLauncherMeterCheckoutLauncher();

  @override
  Future<bool> openHostedCheckout(Uri uri) {
    if (MeterCheckoutUrls.parseSafeHttps(uri.toString()) == null) {
      return Future<bool>.value(false);
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
