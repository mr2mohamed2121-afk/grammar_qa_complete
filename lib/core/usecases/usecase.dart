
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

// Abstract class for all usecases
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Usecase without parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

// No parameters class
class NoParams {
  const NoParams();
}
