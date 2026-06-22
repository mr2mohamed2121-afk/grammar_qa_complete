import 'package:get_it/get_it.dart';
import 'services/firestore_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/usecases/auth_usecases.dart';
import 'features/quiz/presentation/bloc/quiz_bloc.dart';
import 'features/leaderboard/services/leaderboard_service.dart';
import 'features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Services
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
  getIt.registerLazySingleton<LeaderboardService>(() => LeaderboardService());

  // Auth UseCases
  getIt.registerLazySingleton<SignInUseCase>(() => SignInUseCase());
  getIt.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase());
  getIt.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase());
  getIt.registerLazySingleton<GetCurrentUserUseCase>(() => GetCurrentUserUseCase());

  // Auth BLoC
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
    getIt<SignInUseCase>(),
    getIt<SignUpUseCase>(),
    getIt<SignOutUseCase>(),
    getIt<GetCurrentUserUseCase>(),
  ));

  // Quiz
  getIt.registerFactory<QuizBloc>(() => QuizBloc(
    firestoreService: getIt<FirestoreService>(),
  ));

  // Leaderboard
  getIt.registerFactory<LeaderboardBloc>(() => LeaderboardBloc(
    getIt<LeaderboardService>(),
  ));
}