
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../usecases/sign_in.dart';
import '../usecases/sign_up.dart';
import '../usecases/sign_out.dart';
import '../usecases/get_current_user.dart';
import '../../../core/errors/failures.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const SignUpRequested({required this.email, required this.password, required this.name});
  @override
  List<Object?> get props => [email, password, name];
}
class SignOutRequested extends AuthEvent {}
class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested({required this.email});
  @override
  List<Object?> get props => [email];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
class PasswordResetSent extends AuthState {}

// BLoC
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthBloc(
    this._signInUseCase,
    this._signUpUseCase,
    this._signOutUseCase,
    this._getCurrentUserUseCase,
  ) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated()),
    );
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signInUseCase(SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signUpUseCase(SignUpParams(email: event.email, password: event.password, name: event.name));
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // Implement password reset
    emit(PasswordResetSent());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error: ${failure.message}';
      case NetworkFailure:
        return 'Network error: ${failure.message}';
      case AuthFailure:
        return failure.message;
      case CacheFailure:
        return 'Cache error: ${failure.message}';
      default:
        return 'Unexpected error: ${failure.message}';
    }
  }
}
