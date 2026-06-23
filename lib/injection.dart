import 'package:get_it/get_it.dart';
import 'services/firestore_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/usecases/auth_usecases.dart';
import 'features/quiz/presentation/bloc/quiz_bloc.dart';
import 'features/levels/presentation/bloc/levels_bloc.dart';
import 'features/leaderboard/services/leaderboard_service.dart';
import 'features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // ==================== Services ====================
  getIt.registerLazySingleton(() => FirestoreService());
  getIt.registerLazySingleton(() => LeaderboardService());

  // ==================== Auth UseCases ====================
  getIt.registerLazySingleton(() => SignInUseCase());
  getIt.registerLazySingleton(() => SignUpUseCase());
  getIt.registerLazySingleton(() => SignOutUseCase());
  getIt.registerLazySingleton(() => GetCurrentUserUseCase());

  // ==================== Auth BLoC ====================
  getIt.registerFactory(() => AuthBloc(
    getIt<SignInUseCase>(),
    getIt<SignUpUseCase>(),
    getIt<SignOutUseCase>(),
    getIt<GetCurrentUserUseCase>(),
  ));

  // ==================== Levels BLoC (جديد!) ====================
  getIt.registerFactory(() => LevelsBloc(
    firestoreService: getIt<FirestoreService>(),
  ));

  // ==================== Quiz BLoC ====================
  getIt.registerFactory(() => QuizBloc(
    firestoreService: getIt<FirestoreService>(),
  ));

  // ==================== Leaderboard BLoC ====================
  getIt.registerFactory(() => LeaderboardBloc(
    getIt<LeaderboardService>(),
  ));
}