import 'package:eios/data/models/user_model.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState {
  final ProfileStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool logoutSuccess;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.logoutSuccess = false,
  });

  bool get isLoading => status == ProfileStatus.loading;
  bool get isLoaded => status == ProfileStatus.loaded;
  bool get isError => status == ProfileStatus.error;

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? logoutSuccess,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      logoutSuccess: logoutSuccess ?? false,
    );
  }
}
