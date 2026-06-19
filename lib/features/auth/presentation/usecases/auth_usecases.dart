import '../entities/user_entity.dart';

class SignInParams {
  final String email;
  final String password;
  SignInParams({required this.email, required this.password});
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  SignUpParams({required this.email, required this.password, required this.name});
}

class SignInUseCase {
  Future<UserEntity> call(SignInParams params) async {
    // TODO: Implement actual Firebase Auth
    // مؤقت: رجّع user وهمي
    return UserEntity(
      id: '1',
      email: params.email,
      name: 'Test User',
      isAdmin: false,
      isPremium: false,
    );
  }
}

class SignUpUseCase {
  Future<UserEntity> call(SignUpParams params) async {
    // TODO: Implement actual Firebase Auth
    return UserEntity(
      id: '1',
      email: params.email,
      name: params.name,
      isAdmin: false,
      isPremium: false,
    );
  }
}

class SignOutUseCase {
  Future<void> call() async {
    // TODO: Implement actual sign out
  }
}

class GetCurrentUserUseCase {
  Future<UserEntity?> call() async {
    // TODO: Implement actual get current user
    // مؤقت: رجّع null عشان يظهر Login Screen
    return null;
  }
}