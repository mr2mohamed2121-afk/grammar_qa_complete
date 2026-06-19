
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

// ==================== SIGN IN ====================
@injectable
class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepositoryInterface _repository;
  SignInUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await _repository.signInWithEmailAndPassword(
      params.email, params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

// ==================== SIGN UP ====================
@injectable
class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepositoryInterface _repository;
  SignUpUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await _repository.signUpWithEmailAndPassword(
      email: params.email, password: params.password, name: params.name,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  const SignUpParams({required this.email, required this.password, required this.name});
  @override
  List<Object> get props => [email, password, name];
}

// ==================== SIGN OUT ====================
@injectable
class SignOutUseCase implements NoParamsUseCase<void> {
  final AuthRepositoryInterface _repository;
  SignOutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await _repository.signOut();
  }
}

// ==================== GET CURRENT USER ====================
@injectable
class GetCurrentUserUseCase implements NoParamsUseCase<UserEntity?> {
  final AuthRepositoryInterface _repository;
  GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity?>> call() async {
    return await _repository.getCurrentUser();
  }
}

// ==================== RESET PASSWORD ====================
@injectable
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepositoryInterface _repository;
  ResetPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await _repository.resetPassword(params.email);
  }
}

class ResetPasswordParams extends Equatable {
  final String email;
  const ResetPasswordParams({required this.email});
  @override
  List<Object> get props => [email];
}
