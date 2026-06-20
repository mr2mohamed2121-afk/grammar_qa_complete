import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserEntity> call(SignInParams params) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );
      
      final user = result.user;
      if (user == null) throw Exception('Login failed');
      
      return UserEntity(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? 'User',
        isAdmin: false,
        isPremium: false,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}

class SignUpUseCase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserEntity> call(SignUpParams params) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );
      
      final user = result.user;
      if (user == null) throw Exception('Sign up failed');
      
      // Update display name
      await user.updateDisplayName(params.name);
      
      return UserEntity(
        id: user.uid,
        email: user.email!,
        name: params.name,
        isAdmin: false,
        isPremium: false,
      );
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }
}

class SignOutUseCase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> call() async {
    await _auth.signOut();
  }
}

class GetCurrentUserUseCase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserEntity?> call() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    return UserEntity(
      id: user.uid,
      email: user.email!,
      name: user.displayName ?? 'User',
      isAdmin: false,
      isPremium: false,
    );
  }
}