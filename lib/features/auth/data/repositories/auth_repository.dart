
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import 'auth_repository_interface.dart';
import '../datasources/auth_remote_source.dart';
import '../datasources/auth_local_source.dart';

@Injectable(as: AuthRepositoryInterface)
class AuthRepository implements AuthRepositoryInterface {
  final AuthRemoteSource _remoteSource;
  final AuthLocalSource _localSource;

  AuthRepository(this._remoteSource, this._localSource);

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final user = await _remoteSource.signInWithEmailAndPassword(email, password);
      await _localSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _remoteSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      await _localSource.cacheUser(user);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteSource.signOut();
      await _localSource.clearUser();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _remoteSource.resetPassword(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final localUser = await _localSource.getCachedUser();
      if (localUser != null) return Right(localUser);

      final remoteUser = await _remoteSource.getCurrentUser();
      if (remoteUser != null) {
        await _localSource.cacheUser(remoteUser);
      }
      return Right(remoteUser);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteSource.authStateChanges;
  }
}
