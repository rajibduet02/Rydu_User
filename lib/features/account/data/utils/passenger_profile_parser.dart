import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/passenger_profile.dart';
import 'profile_phone.dart';

abstract final class PassengerProfileParser {
  static PassengerProfile parse(dynamic raw) {
    final root = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    var payload = ApiResponseParser.unwrapData(root);
    for (final key in ['profile', 'user', 'passenger']) {
      final nested = payload[key];
      if (nested is Map) {
        payload = Map<String, dynamic>.from(nested);
        break;
      }
    }
    return fromMap(payload);
  }

  static PassengerProfile fromMap(Map<String, dynamic> map) {
    final id = map['id']?.toString() ??
        map['userId']?.toString() ??
        map['_id']?.toString();
    if (id == null || id.trim().isEmpty) {
      throw const FormatException('Profile is missing an id.');
    }

    final name = (map['name'] ?? map['displayName'] ?? '').toString().trim();
    final email = (map['email'] ?? '').toString().trim();
    final image = _string(
      map['profileImageUrl'] ??
          map['avatarUrl'] ??
          map['imageUrl'] ??
          map['photoUrl'],
    );
    final status = _string(map['accountStatus'] ?? map['status']);

    return PassengerProfile(
      id: id.trim(),
      name: name,
      email: email,
      phone: _phone(map['phone']),
      profileImageUrl: image,
      accountStatus: status,
      createdAt: _date(map['createdAt']),
    );
  }

  static String? _phone(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return displayProfilePhone(raw);
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final composed = composeProfilePhone(
        map['countryCode']?.toString() ?? '',
        map['number']?.toString() ?? map['nationalNumber']?.toString() ?? '',
      );
      if (composed != null) return composed;
      return displayProfilePhone(map['e164']?.toString() ?? map['value']?.toString());
    }
    return displayProfilePhone(raw.toString());
  }

  static String? _string(dynamic raw) {
    final value = raw?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static DateTime? _date(dynamic raw) {
    if (raw is DateTime) return raw;
    final value = raw?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
