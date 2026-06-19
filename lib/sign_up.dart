
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

@injectable
class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepositoryInterface _repository;

  SignUpUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await _repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}
