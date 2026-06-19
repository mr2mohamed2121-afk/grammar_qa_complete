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
    // TODO: implement actual sign in
    throw UnimplementedError();
  }
}

class SignUpUseCase {
  Future<UserEntity> call(SignUpParams params) async {
    // TODO: implement actual sign up
    throw UnimplementedError();
  }
}

class SignOutUseCase {
  Future<void> call() async {
    // TODO: implement actual sign out
  }
}

class GetCurrentUserUseCase {
  Future<UserEntity?> call() async {
    // TODO: implement actual get current user
    return null;
  }
}