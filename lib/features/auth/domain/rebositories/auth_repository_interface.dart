
import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepositoryInterface {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
