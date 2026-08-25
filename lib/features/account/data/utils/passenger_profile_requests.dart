import 'package:dio/dio.dart';

/// JSON bodies for passenger profile PATCH. Email is never included.
abstract final class PassengerProfileRequests {
  static const avatarField = 'avatar';
  static const maxAvatarBytes = 5 * 1024 * 1024;

  static Map<String, dynamic> patchName(String name) => {'name': name.trim()};

  static Map<String, dynamic> patchPhone({
    required String countryCode,
    required String number,
  }) {
    return {
      'phone': {
        'countryCode': countryCode.trim(),
        'number': number.trim().replaceAll(RegExp(r'\D'), ''),
      },
    };
  }

  static Map<String, dynamic> patchPhoneClear() => {'phone': null};

  static Map<String, dynamic> patch({
    String? name,
    Object? phone,
    bool clearPhone = false,
  }) {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (clearPhone) {
      body['phone'] = null;
    } else if (phone != null) {
      body['phone'] = phone;
    }
    return body;
  }

  static Map<String, dynamic> deactivate({required bool confirm}) => {
    'confirm': confirm,
  };

  static FormData avatarFormData({
    required List<int> bytes,
    String filename = 'avatar.jpg',
  }) {
    return FormData.fromMap({
      avatarField: MultipartFile.fromBytes(bytes, filename: filename),
    });
  }
}
