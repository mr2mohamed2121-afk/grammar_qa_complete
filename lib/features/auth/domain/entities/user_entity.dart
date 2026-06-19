
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;
  final bool isPremium;
  final String? photoUrl;
  final DateTime createdAt;
  final String? premiumPlan;
  final DateTime? premiumExpiresAt;
  final int? availableCards;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
    this.isPremium = false,
    this.photoUrl,
    required this.createdAt,
    this.premiumPlan,
    this.premiumExpiresAt,
    this.availableCards,
  });

  @override
  List<Object?> get props => [
    id, email, name, isAdmin, isPremium, photoUrl, 
    createdAt, premiumPlan, premiumExpiresAt, availableCards,
  ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    bool? isAdmin,
    bool? isPremium,
    String? photoUrl,
    DateTime? createdAt,
    String? premiumPlan,
    DateTime? premiumExpiresAt,
    int? availableCards,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      isPremium: isPremium ?? this.isPremium,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      availableCards: availableCards ?? this.availableCards,
    );
  }
}
