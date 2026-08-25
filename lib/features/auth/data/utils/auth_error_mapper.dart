import 'dart:io';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:dio/dio.dart';

import '../../domain/exceptions/auth_exception.dart';

abstract final class AuthErrorMapper {
  static AuthException fromDio(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;
    final extracted = _extract(response?.data);
    var message =
        extracted?.message ??
        switch (error.type) {
          DioExceptionType.connectionTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.sendTimeout =>
            'Connection timed out. Please try again.',
          DioExceptionType.connectionError =>
            'Network error. Check your connection and try again.',
          _ => 'Something went wrong. Please try again.',
        };
    final code = extracted?.code;

    if (code == 'ACCOUNT_DEACTIVATED' ||
        (statusCode == 403 &&
            message.toLowerCase().contains('deactivat'))) {
      return AuthException(
        'This account has been deactivated. Contact support if you need it reactivated.',
        statusCode: statusCode,
        code: 'ACCOUNT_DEACTIVATED',
      );
    }

    if (statusCode == 401) {
      return AuthException(
        message == 'Something went wrong. Please try again.'
            ? 'Invalid email or password.'
            : message,
        statusCode: statusCode,
        code: code,
      );
    }
    if (statusCode == 409) {
      return AuthException(
        message.toLowerCase().contains('email')
            ? message
            : 'An account with this email already exists.',
        statusCode: statusCode,
        code: code,
      );
    }
    return AuthException(message, statusCode: statusCode, code: code);
  }

  static AuthException fromAuth0(Object error) {
    if (error is ApiException) {
      if (error.isInvalidCredentials) {
        return const AuthException('Invalid email or password.');
      }
      if (error.isPasswordNotStrongEnough || error.isPasswordLeaked) {
        return AuthException(_humanize(error.message));
      }
      if (error.isNetworkError) {
        return const AuthException(
          'Network error. Check your connection and try again.',
        );
      }
      if (error.isTooManyAttempts) {
        return const AuthException(
          'Too many attempts. Please wait and try again.',
        );
      }
      if (error.isAccessDenied) {
        return const AuthException(
          'Unable to sign in. Check your email and password.',
        );
      }
      return AuthException(_humanize(error.message));
    }
    if (error is SocketException) {
      return const AuthException(
        'Network error. Check your connection and try again.',
      );
    }
    return AuthException(_humanize(error.toString()));
  }

  static ({String? code, String? message})? _extract(dynamic data) {
    if (data is String && data.trim().isNotEmpty) {
      return (code: null, message: _humanize(data.trim()));
    }
    if (data is! Map) return null;

    final map = Map<String, dynamic>.from(data);
    String? code;
    String? message;

    final errorField = map['error'];
    if (errorField is Map) {
      final nested = Map<String, dynamic>.from(errorField);
      code = nested['code']?.toString();
      final nestedMessage = nested['message'];
      if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
        message = _humanize(nestedMessage.trim(), code: code);
      }
    } else if (errorField is String && errorField.trim().isNotEmpty) {
      message = _humanize(errorField.trim());
    }

    if (message == null) {
      for (final key in ['message', 'detail', 'title']) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          message = _humanize(value.trim(), code: code);
          break;
        }
      }
    }

    if (message == null) {
      final errors = map['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is String) {
          message = _humanize(first);
        } else if (first is Map) {
          final nested = first['message'] ?? first['error'];
          if (nested is String && nested.trim().isNotEmpty) {
            message = _humanize(nested.trim(), code: code);
          }
        }
      }
    }

    if (message == null && code == null) return null;
    return (code: code, message: message);
  }

  static String _humanize(String message, {String? code}) {
    final lower = message.toLowerCase();

    if (code == 'REGISTRATION_FAILED' &&
        (lower.contains('too weak') || lower.contains('passwordstrength'))) {
      return 'Password is too weak. Use at least 8 characters with uppercase, lowercase, numbers, and symbols.';
    }
    if (code == 'REGISTRATION_FAILED' &&
        lower.contains('user already exists')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('passwordstrength') || lower.contains('too weak')) {
      return 'Password is too weak. Use at least 8 characters with uppercase, lowercase, numbers, and symbols.';
    }
    if (lower.contains('user already exists') ||
        lower.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('invalid email')) {
      return 'Enter a valid email address.';
    }

    var cleaned = message;
    if (cleaned.startsWith('Auth0:')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^Auth0:\s*'), '');
    }
    cleaned = cleaned.replaceFirst(RegExp(r'^[A-Za-z]+Error:\s*'), '');

    return cleaned.trim().isEmpty ? message : cleaned.trim();
  }
}
