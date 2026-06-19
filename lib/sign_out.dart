
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../repositories/auth_repository_interface.dart';

@injectable
class SignOutUseCase implements NoParamsUseCase<void> {
  final AuthRepositoryInterface _repository;

  SignOutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await _repository.signOut();
  }
}
