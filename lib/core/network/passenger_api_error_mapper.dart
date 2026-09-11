import 'package:dio/dio.dart';

import '../payments/rydu_payments.dart';

/// Passenger API failure with a user-friendly message.
class PassengerApiException implements Exception {
  const PassengerApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.details,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  String toString() => message;
}

abstract final class PassengerApiErrorMapper {
  static PassengerApiException fromDio(DioException error) {
    final status = error.response?.statusCode;
    final extracted = _extract(error.response?.data);
    final code = extracted?.code;
    final message = extracted?.message;

    final stripeMapped = userMessageForCode(code);
    if (stripeMapped != null) {
      return PassengerApiException(
        stripeMapped,
        code: code,
        statusCode: status,
        details: extracted?.details,
      );
    }

    if (status == 401) {
      return PassengerApiException(
        message ?? 'Session expired. Please sign in again.',
        code: code ?? 'UNAUTHORIZED',
        statusCode: status,
        details: extracted?.details,
      );
    }
    if (status == 403) {
      if (code == 'ACCOUNT_DEACTIVATED') {
        return PassengerApiException(
          'This account has been deactivated. Contact support if you need it reactivated.',
          code: code,
          statusCode: status,
          details: extracted?.details,
        );
      }
      return PassengerApiException(
        message ?? 'You do not have permission to perform this action.',
        code: code ?? 'FORBIDDEN',
        statusCode: status,
        details: extracted?.details,
      );
    }
    if (status == 404) {
      return PassengerApiException(
        message ?? 'Requested resource was not found.',
        code: code ?? 'NOT_FOUND',
        statusCode: status,
        details: extracted?.details,
      );
    }
    if (status == 429) {
      return PassengerApiException(
        message ?? 'Too many requests. Please wait and try again.',
        code: code ?? 'RATE_LIMITED',
        statusCode: status,
        details: extracted?.details,
      );
    }
    if (status == 503) {
      return PassengerApiException(
        message ?? 'Map service is temporarily unavailable. Please try again.',
        code: code ?? 'MAP_SERVICE_UNAVAILABLE',
        statusCode: status,
        details: extracted?.details,
      );
    }

    final fallback = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => 'Connection timed out. Please try again.',
      DioExceptionType.connectionError =>
        'Network error. Check your connection and try again.',
      _ => 'Something went wrong. Please try again.',
    };

    return PassengerApiException(
      message ?? fallback,
      code: code,
      statusCode: status,
      details: extracted?.details,
    );
  }

  static PassengerApiException? fromEnvelope(dynamic raw) {
    if (raw is! Map) return null;
    final root = Map<String, dynamic>.from(raw);
    if (root['success'] != false) return null;
    final extracted = _extract(root);
    return PassengerApiException(
      userMessageForCode(extracted?.code) ??
          extracted?.message ??
          'Something went wrong. Please try again.',
      code: extracted?.code,
      details: extracted?.details,
    );
  }

  /// Maps known payment/Stripe backend codes to user-safe copy.
  static String? userMessageForCode(String? code) {
    switch (code) {
      case 'CARD_PAYMENTS_NOT_ENABLED':
      case 'STRIPE_MODE_MISMATCH':
      case 'STRIPE_NOT_CONFIGURED':
      case 'STRIPE_CURRENCY_UNSUPPORTED':
        return RyduPayments.cardUnavailableMessage;
      default:
        return null;
    }
  }

  static ({String? code, String? message, Map<String, dynamic>? details})?
  _extract(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      return (code: null, message: data.trim(), details: null);
    }
    if (data is! Map) return null;
    final root = Map<String, dynamic>.from(data);
    final error = root['error'];
    if (error is Map) {
      final map = Map<String, dynamic>.from(error);
      final detailsRaw = map['details'];
      return (
        code: map['code']?.toString(),
        message: map['message']?.toString(),
        details: detailsRaw is Map
            ? Map<String, dynamic>.from(detailsRaw)
            : null,
      );
    }
    return (
      code: root['code']?.toString(),
      message: root['message']?.toString(),
      details: null,
    );
  }
}
