// lib/src/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final userOrFailure = await authRepository.getCurrentUser();
      if (emit.isDone) return;
      userOrFailure.fold(
            (f) => emit(const AuthUnauthenticated()),
            (user) => emit(AuthAuthenticated(user: user)),
      );
    } catch (e, st) {
      // unexpected
      if (!emit.isDone) emit(AuthFailureState(message: e.toString()));
      print('AppStarted error: $e\n$st');
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    print('AuthBloc: LoginRequested username=${event.username}');

    try {
      final result = await authRepository.login(event.username, event.password);
      if (emit.isDone) return;

      // IMPORTANT: await the fold so the handler stays alive while async code runs
      await result.fold(
            (failure) async {
          print('AuthBloc: login failure -> ${failure.message}');
          if (!emit.isDone) emit(AuthFailureState(message: failure.message));
        },
            (token) async {
          print('AuthBloc: login success token=${token.accessToken.substring(0, token.accessToken.length.clamp(0, 8))}...');
          if (emit.isDone) return;

          // try to load user
          final userRes = await authRepository.getCurrentUser();
          if (emit.isDone) return;

          userRes.fold(
                (f) {
              print('AuthBloc: getCurrentUser failed -> ${f.message}. Emitting placeholder user.');
              if (!emit.isDone) {
                emit(AuthAuthenticated(user: User(id: '0', email: event.username, name: event.username)));
              }
            },
                (user) {
              print('AuthBloc: getCurrentUser success -> ${user.email}');
              if (!emit.isDone) emit(AuthAuthenticated(user: user));
            },
          );
        },
      );
    } catch (e, st) {
      print('AuthBloc: unexpected error during login -> $e\n$st');
      if (!emit.isDone) emit(AuthFailureState(message: 'Unexpected error: ${e.toString()}'));
    }
  }


  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.logout();
      if (emit.isDone) return;
      emit(const AuthUnauthenticated());
    } catch (e) {
      if (!emit.isDone) emit(AuthFailureState(message: e.toString()));
    }
  }
}
