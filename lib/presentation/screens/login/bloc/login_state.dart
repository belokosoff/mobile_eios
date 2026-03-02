enum LoginStatus { initial, checking, loading, success, error }

class LoginState {
  final LoginStatus status;
  final String errorMessage;

  const LoginState({this.status = LoginStatus.initial, this.errorMessage = ''});

  bool get isLoading => status == LoginStatus.loading;
  bool get isChecking => status == LoginStatus.checking;
  bool get isSuccess => status == LoginStatus.success;
  bool get hasError => errorMessage.isNotEmpty;

  LoginState copyWith({LoginStatus? status, String? errorMessage}) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
