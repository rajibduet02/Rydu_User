import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/network/profile_image_url.dart';
import 'package:rydu_user/features/account/data/utils/passenger_profile_parser.dart';
import 'package:rydu_user/features/account/data/utils/passenger_profile_requests.dart';
import 'package:rydu_user/features/account/data/utils/profile_phone.dart';

void main() {
  group('PassengerProfileParser', () {
    test('1. GET profile parsing from data envelope', () {
      final profile = PassengerProfileParser.parse({
        'success': true,
        'data': {
          'id': 'user-1',
          'name': 'Test Passenger',
          'email': 'test@example.com',
          'phone': '+14155550123',
          'profileImageUrl': '/uploads/avatars/passengers/x.jpg',
          'accountStatus': 'active',
          'createdAt': '2026-08-01T10:00:00.000Z',
        },
      });

      expect(profile.id, 'user-1');
      expect(profile.name, 'Test Passenger');
      expect(profile.email, 'test@example.com');
      expect(profile.phone, '+14155550123');
      expect(profile.profileImageUrl, '/uploads/avatars/passengers/x.jpg');
      expect(profile.accountStatus, 'active');
      expect(profile.createdAt, isNotNull);
    });

    test('parses nested phone object', () {
      final profile = PassengerProfileParser.parse({
        'data': {
          'id': '1',
          'name': 'A',
          'email': 'a@b.com',
          'phone': {'countryCode': '+44', 'number': '7700900000'},
        },
      });
      expect(profile.phone, '+447700900000');
    });
  });

  group('PassengerProfileRequests', () {
    test('7. Name PATCH body', () {
      expect(PassengerProfileRequests.patchName(' Ada '), {'name': 'Ada'});
    });

    test('8. Phone PATCH body', () {
      expect(
        PassengerProfileRequests.patchPhone(
          countryCode: '+880',
          number: '1712345678',
        ),
        {
          'phone': {'countryCode': '+880', 'number': '1712345678'},
        },
      );
    });

    test('9. Phone null body', () {
      expect(PassengerProfileRequests.patchPhoneClear(), {'phone': null});
    });

    test('10. Email never PATCHed', () {
      final nameBody = PassengerProfileRequests.patchName('Ada');
      final phoneBody = PassengerProfileRequests.patchPhone(
        countryCode: '+1',
        number: '4155550100',
      );
      final clearBody = PassengerProfileRequests.patchPhoneClear();
      final combined = PassengerProfileRequests.patch(
        name: 'Ada',
        clearPhone: true,
      );
      for (final body in [nameBody, phoneBody, clearBody, combined]) {
        expect(body.containsKey('email'), isFalse);
      }
    });

    test('12. Avatar multipart field is avatar', () {
      expect(PassengerProfileRequests.avatarField, 'avatar');
      final form = PassengerProfileRequests.avatarFormData(
        bytes: [1, 2, 3],
        filename: 'photo.png',
      );
      expect(form.files, isNotEmpty);
      expect(form.files.first.key, 'avatar');
      expect(form.files.first.value.filename, 'photo.png');
    });
  });

  group('resolveProfileImageUrl', () {
    test('13. Relative avatar URL resolution', () {
      expect(
        resolveProfileImageUrl(
          '/uploads/avatars/passengers/x.jpg',
          baseUrl: 'http://103.208.181.253:3000',
        ),
        'http://103.208.181.253:3000/uploads/avatars/passengers/x.jpg',
      );
      expect(
        resolveProfileImageUrl(
          '/uploads/avatars/passengers/x.jpg',
          baseUrl: 'http://103.208.181.253:3000/api/v1/passenger',
        ),
        'http://103.208.181.253:3000/uploads/avatars/passengers/x.jpg',
      );
      expect(
        resolveProfileImageUrl(
          'https://cdn.example.com/a.jpg',
          baseUrl: 'http://103.208.181.253:3000',
        ),
        'https://cdn.example.com/a.jpg',
      );
    });
  });

  group('splitProfilePhone', () {
    test('does not assume Bangladesh for other country codes', () {
      final us = splitProfilePhone('+14155550123');
      expect(us.countryCode, '+1');
      expect(us.number, '4155550123');

      final uk = splitProfilePhone('+447700900000');
      expect(uk.countryCode, '+44');
      expect(uk.number, '7700900000');

      final bd = splitProfilePhone('+8801712345678');
      expect(bd.countryCode, '+880');
      expect(bd.number, '1712345678');
    });
  });
}
