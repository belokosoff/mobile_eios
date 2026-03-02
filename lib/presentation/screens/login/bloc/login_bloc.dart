import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eios/data/repositories/auth_repository.dart';
import 'package:eios/data/repositories/user_repository.dart';
import 'package:eios/data/storage/token_storage.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  LoginBloc({AuthRepository? authRepository, UserRepository? userRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      _userRepository = userRepository ?? UserRepository(),
      super(const LoginState()) {
    on<LoginCheckToken>(_onCheckToken);
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onCheckToken(
    LoginCheckToken event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.checking));

    final token = await TokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(status: LoginStatus.success));
    } else {
      emit(state.copyWith(status: LoginStatus.initial));
    }
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    final success = await _authRepository.login(
      event.email.trim(),
      event.password,
    );

    if (!success) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          errorMessage: 'Неверный логин или пароль',
        ),
      );
      return;
    }

    try {
      final userModel = await _userRepository.getUserProfile();
      final prefs = await SharedPreferences.getInstance();

      if (userModel.id != null) {
        await prefs.setString('user_id', userModel.id!);
        debugPrint('Успешно сохранили ID: ${userModel.id}');
      }
    } catch (e) {
      debugPrint('Не удалось получить ID пользователя: $e');
    }

    emit(state.copyWith(status: LoginStatus.success));
  }
}
