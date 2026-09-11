import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// TEMPORARY Stripe/Card QA logs. Prefix: `[STRIPE_DEBUG]`.
///
/// Remove this file and all `StripeDebug` call sites after device QA.
/// Never logs JWT, Stripe secrets, full publishable keys, clientSecret, or card data.
abstract final class StripeDebug {
  static const prefix = '[STRIPE_DEBUG]';

  /// Set by the payment poller so GET /payment logs can include attempt=.
  static int? pollAttempt;

  static bool? lastStripeEnabled;
  static bool? lastCardEnabled;
  static bool? lastPublishableKeyValid;
  static bool? lastStripeSdkInitialized;
  static bool? lastBackendReturnedCard;
  static String? lastUnavailableReason;

  static void log(String message) {
    if (!kDebugMode) return;
    debugPrint('$prefix $message');
  }

  static void resetAvailability() {
    lastStripeEnabled = null;
    lastCardEnabled = null;
    lastPublishableKeyValid = null;
    lastStripeSdkInitialized = null;
    lastBackendReturnedCard = null;
    lastUnavailableReason = null;
  }

  static String requestUrl(Dio dio, String path) {
    final base = dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final rel = path.startsWith('/') ? path : '/$path';
    return '$base$rel';
  }

  static String publishableKeyMode(String? key) {
    final value = (key ?? '').trim();
    if (value.startsWith('pk_live')) return 'live';
    if (value.startsWith('pk_test')) return 'test';
    if (value.startsWith('pk_')) return 'unknown';
    return 'invalid';
  }

  static String maskPublishableKey(String? key) {
    final value = (key ?? '').trim();
    if (value.isEmpty) return '';
    if (!value.startsWith('pk_')) return 'invalid';
    final last4 = value.length <= 4 ? value : value.substring(value.length - 4);
    return 'pk_${publishableKeyMode(value)}_****$last4';
  }

  static String encodeSanitized(dynamic raw) {
    try {
      return jsonEncode(sanitize(raw));
    } catch (_) {
      return sanitize(raw).toString();
    }
  }

  static dynamic sanitize(dynamic raw) {
    if (raw is Map) {
      final out = <String, dynamic>{};
      raw.forEach((key, value) {
        final name = key.toString();
        final lower = name.toLowerCase().replaceAll('_', '');
        if (lower.contains('authorization') ||
            lower.contains('bearer') ||
            lower == 'token' ||
            lower == 'accesstoken' ||
            lower == 'idtoken') {
          out[name] = '***redacted***';
          return;
        }
        if (lower.contains('clientsecret')) {
          final present = value != null && value.toString().trim().isNotEmpty;
          out[name] = present ? '***present***' : '';
          return;
        }
        if (lower.contains('webhooksecret') ||
            lower.contains('stripesecret') ||
            lower == 'secretkey' ||
            lower == 'secret') {
          out[name] = '***redacted***';
          return;
        }
        if (lower.contains('publishablekey')) {
          out[name] = maskPublishableKey(value?.toString());
          return;
        }
        out[name] = sanitize(value);
      });
      return out;
    }
    if (raw is List) {
      return raw.map(sanitize).toList();
    }
    if (raw is String) {
      return redactSecretsInText(raw);
    }
    return raw;
  }

  static String redactSecretsInText(String value) {
    var text = value;
    text = text.replaceAllMapped(
      RegExp(r'pk_(test|live)_[A-Za-z0-9]+'),
      (m) => maskPublishableKey(m.group(0)),
    );
    text = text.replaceAll(RegExp(r'sk_(test|live)_[A-Za-z0-9]+'), 'sk_***');
    text = text.replaceAll(RegExp(r'whsec_[A-Za-z0-9]+'), 'whsec_***');
    text = text.replaceAll(
      RegExp(r'(pi|seti)_[A-Za-z0-9]+_secret_[A-Za-z0-9]+'),
      '***clientSecret***',
    );
    text = text.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9._\-]+', caseSensitive: false),
      'Bearer ***redacted***',
    );
    return text;
  }

  static void httpGet({
    required String url,
    required int? status,
    required dynamic body,
  }) {
    log('GET $url');
    log('status=$status');
    log('body=${encodeSanitized(body)}');
  }

  static void httpPost({
    required String url,
    required int? status,
    required dynamic body,
  }) {
    log('POST $url');
    log('status=$status');
    log('body=${encodeSanitized(body)}');
  }

  static void paymentConfigParsed({
    required bool stripeEnabled,
    required bool cardEnabled,
    required String? publishableKey,
  }) {
    final key = publishableKey?.trim() ?? '';
    log('stripeEnabled=$stripeEnabled');
    log('cardEnabled=$cardEnabled');
    log('publishableKeyPresent=${key.isNotEmpty}');
    log('publishableKeyMode=${key.isEmpty ? 'missing' : publishableKeyMode(key)}');
    if (key.isNotEmpty) {
      log('publishableKey=${maskPublishableKey(key)}');
    }
  }

  static void paymentMethodsParsed({
    required List<String> codes,
    required bool cardReturnedByBackend,
    String? selectedPaymentMethod,
  }) {
    log('paymentMethods=[${codes.join(', ')}]');
    log('cardReturnedByBackend=$cardReturnedByBackend');
    if (selectedPaymentMethod != null) {
      log('selectedPaymentMethod=$selectedPaymentMethod');
    }
  }

  static void dumpCardAvailability({required bool finalCardAvailable}) {
    log('cardAvailabilityCheck');
    log('stripeEnabled=$lastStripeEnabled');
    log('cardEnabled=$lastCardEnabled');
    log('publishableKeyValid=$lastPublishableKeyValid');
    log('backendReturnedCard=$lastBackendReturnedCard');
    log('stripeSdkInitialized=$lastStripeSdkInitialized');
    log('finalCardAvailable=$finalCardAvailable');
    if (!finalCardAvailable) {
      log(
        'CARD UNAVAILABLE REASON: ${lastUnavailableReason ?? 'unknown'}',
      );
    }
  }

  static void apiError({
    required String endpoint,
    int? statusCode,
    dynamic responseBody,
    String? exceptionType,
    Object? error,
  }) {
    log('API ERROR');
    log('endpoint=$endpoint');
    log('statusCode=$statusCode');
    log('responseBody=${encodeSanitized(responseBody)}');
    log('exceptionType=${exceptionType ?? error?.runtimeType}');
    if (error != null) {
      log('error=${redactSecretsInText(error.toString())}');
    }
  }

  static void createBookingResult({
    required String? bookingId,
    required String? bookingStatus,
    required String? paymentMethod,
    required String? paymentStatus,
    required String? paymentIntentId,
    required bool clientSecretPresent,
  }) {
    log('bookingId=$bookingId');
    log('bookingStatus=$bookingStatus');
    log('paymentMethod=$paymentMethod');
    log('paymentStatus=$paymentStatus');
    log('paymentIntentId=${paymentIntentId ?? ''}');
    log('clientSecretPresent=$clientSecretPresent');
  }

  static void paymentStatus({
    required String bookingId,
    required String status,
    required String? paymentIntentId,
    required bool clientSecretPresent,
    int? attempt,
  }) {
    if (attempt != null) {
      log('paymentPoll attempt=$attempt');
    }
    log('bookingId=$bookingId');
    log('status=$status');
    log('paymentIntentId=${paymentIntentId ?? ''}');
    log('clientSecretPresent=$clientSecretPresent');
  }
}
