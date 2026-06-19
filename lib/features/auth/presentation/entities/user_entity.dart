class UserEntity {
  final String id;
  final String email;
  final String? name;
  final bool isAdmin;
  final bool isPremium;

  UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.isAdmin = false,
    this.isPremium = false,
  });
}