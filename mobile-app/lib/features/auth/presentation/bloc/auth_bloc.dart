import 'package:bemyvoice/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:bemyvoice/core/usecase/usecase.dart';
import 'package:bemyvoice/core/common/entities/user.dart';
import 'package:bemyvoice/features/auth/domain/usecases/current_user.dart';
import 'package:bemyvoice/features/auth/domain/usecases/user_login.dart';
import 'package:bemyvoice/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onSignUp);
    on<AuthLogin>(_onLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLoginWithGoogle>(_onLoginWithGoogle);
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  Future<void> _onSignUp(
    AuthSignUp event,
    Emitter<AuthState> emit,
  ) async {
    // Password matching validation
    if (event.password != event.confirmPassword) {
      emit(AuthFailure("Passwords do not match"));
      return; // Exit early if validation fails
    }

    // Proceed with the sign-up process if passwords match
    final res = await _userSignUp(
      UserSignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      ),
    );

    // Emit corresponding states based on the result
    res.fold(
      (failure) {
        print('Sign-up failed: ${failure.message}');
        emit(AuthFailure(failure.message));
      },
      (user) {
        print('User signed up successfully: ${user.email}');
        _emitAuthSuccess(user, emit);
      },
    );
  }

  Future<void> _onLogin(
    AuthLogin event,
    Emitter<AuthState> emit,
  ) async {
    // Proceed with the login process
    final res = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    // Emit corresponding states based on the result
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => {
        print('User logged in successfully: ${user.gender}'),
        _emitAuthSuccess(user, emit),
      },
    );
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }

  void _onLoginWithGoogle(
    AuthLoginWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final User user = event.userCredential;

      // Call _emitAuthSuccess to update the AppUserCubit and AuthState
      _emitAuthSuccess(user, emit);
    } catch (e) {
      emit(AuthFailure("Failed to log in with Google"));
    }
  }
}
