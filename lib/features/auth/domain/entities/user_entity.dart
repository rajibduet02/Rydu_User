class UserEntity {
  const UserEntity({required this.id, this.email, this.displayName, this.role});

  final String id;
  final String? email;
  final String? displayName;
  final String? role;
}
