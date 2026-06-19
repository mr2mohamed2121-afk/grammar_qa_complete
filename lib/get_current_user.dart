
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository_interface.dart';

@injectable
class GetCurrentUserUseCase implements NoParamsUseCase<UserEntity?> {
  final AuthRepositoryInterface _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity?>> call() async {
    return await _repository.getCurrentUser();
  }
}
