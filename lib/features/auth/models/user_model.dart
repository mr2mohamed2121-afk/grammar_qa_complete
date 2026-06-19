class UserModel {
  final String id;
  final String email;
  final String? name;
  final bool isAdmin;
  final bool isPremium;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.isAdmin = false,
    this.isPremium = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      isAdmin: json['isAdmin'] ?? false,
      isPremium: json['isPremium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isAdmin': isAdmin,
      'isPremium': isPremium,
    };
  }
}