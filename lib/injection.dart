import 'package:get_it/get_it.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/usecases/auth_usecases.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  // UseCases
  getIt.registerLazySingleton<SignInUseCase>(() => SignInUseCase());
  getIt.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase());
  getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase());
  getIt.registerLazySingleton<GetCurrentUserUseCase>(() => GetCurrentUserUseCase());

  // Bloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      getIt<SignInUseCase>(),
      getIt<SignUpUseCase>(),
      getIt<SignOutUseCase>(),
      getIt<GetCurrentUserUseCase>(),
    ),
  );
}