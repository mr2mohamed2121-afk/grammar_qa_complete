
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

@injectable
class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepositoryInterface _repository;

  SignInUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await _repository.signInWithEmailAndPassword(
      params.email,
      params.password,
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
