class ProfilePhoneParts {
  const ProfilePhoneParts({required this.countryCode, required this.number});

  final String countryCode;
  final String number;

  bool get isEmpty => countryCode.trim().isEmpty && number.trim().isEmpty;
}

/// Longest-first calling codes so `+880` is not split as `+8` / `80`.
const List<String> kProfileCallingCodes = [
  '+880',
  '+971',
  '+966',
  '+977',
  '+886',
  '+853',
  '+852',
  '+598',
  '+595',
  '+593',
  '+420',
  '+358',
  '+353',
  '+351',
  '+256',
  '+255',
  '+254',
  '+251',
  '+250',
  '+249',
  '+237',
  '+234',
  '+233',
  '+225',
  '+221',
  '+218',
  '+216',
  '+213',
  '+212',
  '+94',
  '+92',
  '+91',
  '+90',
  '+86',
  '+84',
  '+82',
  '+81',
  '+66',
  '+65',
  '+64',
  '+63',
  '+62',
  '+61',
  '+60',
  '+58',
  '+57',
  '+56',
  '+55',
  '+54',
  '+52',
  '+51',
  '+49',
  '+48',
  '+47',
  '+46',
  '+44',
  '+43',
  '+41',
  '+39',
  '+36',
  '+34',
  '+33',
  '+32',
  '+31',
  '+30',
  '+27',
  '+20',
  '+7',
  '+1',
];

/// Splits a backend phone string for edit fields only.
///
/// Does not assume Bangladesh when the value already contains another code.
ProfilePhoneParts splitProfilePhone(String? raw) {
  final digitsAndPlus = (raw ?? '').trim().replaceAll(RegExp(r'[\s()-]'), '');
  if (digitsAndPlus.isEmpty) {
    return const ProfilePhoneParts(countryCode: '', number: '');
  }
  if (digitsAndPlus.startsWith('+')) {
    for (final code in kProfileCallingCodes) {
      if (digitsAndPlus.startsWith(code)) {
        return ProfilePhoneParts(
          countryCode: code,
          number: digitsAndPlus.substring(code.length),
        );
      }
    }
    return ProfilePhoneParts(countryCode: '+', number: digitsAndPlus.substring(1));
  }
  return ProfilePhoneParts(countryCode: '', number: digitsAndPlus);
}

String? composeProfilePhone(String countryCode, String number) {
  final code = countryCode.trim();
  final num = number.trim().replaceAll(RegExp(r'\D'), '');
  if (code.isEmpty && num.isEmpty) return null;
  if (num.isEmpty) return null;
  if (code.isEmpty) return num;
  final normalizedCode = code.startsWith('+') ? code : '+$code';
  return '$normalizedCode$num';
}

String? displayProfilePhone(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}
