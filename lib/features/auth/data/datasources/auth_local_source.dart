
import 'package:injectable/injectable.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/errors/exceptions.dart';
import '../entities/user_entity.dart';

@injectable
class AuthLocalSource {
  final LocalStorageService _localStorage;

  AuthLocalSource(this._localStorage);

  Future<void> cacheUser(UserEntity user) async {
    try {
      await _localStorage.saveUserData({
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'isAdmin': user.isAdmin,
        'isPremium': user.isPremium,
        'photoUrl': user.photoUrl,
        'createdAt': user.createdAt.toIso8601String(),
        'premiumPlan': user.premiumPlan,
        'premiumExpiresAt': user.premiumExpiresAt?.toIso8601String(),
        'availableCards': user.availableCards,
      });
      await _localStorage.saveUserId(user.id);
      await _localStorage.setIsAdmin(user.isAdmin);
      await _localStorage.setPremiumStatus(user.isPremium);
      if (user.premiumExpiresAt != null) {
        await _localStorage.setPremiumExpiry(user.premiumExpiresAt!);
      }
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  Future<UserEntity?> getCachedUser() async {
    try {
      final data = _localStorage.getUserData();
      if (data == null) return null;

      return UserEntity(
        id: data['id'] ?? '',
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        isAdmin: data['isAdmin'] ?? false,
        isPremium: data['isPremium'] ?? false,
        photoUrl: data['photoUrl'],
        createdAt: DateTime.parse(data['createdAt']),
        premiumPlan: data['premiumPlan'],
        premiumExpiresAt: data['premiumExpiresAt'] != null
            ? DateTime.parse(data['premiumExpiresAt'])
            : null,
        availableCards: data['availableCards'],
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      await _localStorage.clearUserData();
      await _localStorage.clearUserId();
      await _localStorage.clearAuthToken();
    } catch (e) {
      throw CacheException('Failed to clear user: $e');
    }
  }
}
