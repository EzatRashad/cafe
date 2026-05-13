import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final hasPass = await _repo.hasPassword();
      if (!hasPass) {
        emit(AuthNeedsSetup());
        return;
      }
      final remember = await _repo.getRememberMe();
      final loggedIn = await _repo.isLoggedIn();
      if (remember && loggedIn) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthNeedsLogin());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> createPassword(String password, String confirm) async {
    if (password.length < 4) {
      emit(AuthValidationError('passwordTooShort'));
      return;
    }
    if (password != confirm) {
      emit(AuthValidationError('passwordsNoMatch'));
      return;
    }
    emit(AuthLoading());
    try {
      await _repo.createPassword(password);
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String password, {bool rememberMe = false}) async {
    emit(AuthLoading());
    try {
      final ok = await _repo.verifyPassword(password);
      if (ok) {
        await _repo.setRememberMe(rememberMe);
        emit(AuthAuthenticated());
      } else {
        emit(AuthValidationError('wrongPassword'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(AuthNeedsLogin());
  }
}
