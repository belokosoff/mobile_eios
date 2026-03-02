import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eios/data/repositories/user_repository.dart';
import 'package:eios/data/storage/token_storage.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;

  ProfileBloc({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository(),
      super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileRefreshed>(_onRefreshed);
    on<ProfileLogoutRequested>(_onLogout);
  }

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    try {
      final user = await _userRepository.getUserProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, user: user));
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRefreshed(
    ProfileRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    try {
      final user = await _userRepository.getUserProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, user: user));
    } catch (e) {
      emit(
        state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLogout(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await TokenStorage.logout();
      emit(state.copyWith(logoutSuccess: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Ошибка выхода: $e'));
    }
  }
}
