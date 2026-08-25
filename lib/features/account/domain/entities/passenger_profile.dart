class PassengerProfile {
  const PassengerProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    this.accountStatus,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final String? accountStatus;
  final DateTime? createdAt;

  bool get hasAvatar =>
      profileImageUrl != null && profileImageUrl!.trim().isNotEmpty;

  String get displayName {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) return trimmed;
    final mail = email.trim();
    if (mail.isNotEmpty) return mail;
    return 'Account';
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  PassengerProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? accountStatus,
    DateTime? createdAt,
    bool clearPhone = false,
    bool clearAvatar = false,
  }) {
    return PassengerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: clearPhone ? null : (phone ?? this.phone),
      profileImageUrl: clearAvatar
          ? null
          : (profileImageUrl ?? this.profileImageUrl),
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
