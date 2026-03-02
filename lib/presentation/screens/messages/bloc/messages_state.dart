import 'package:equatable/equatable.dart';
import 'package:eios/data/models/message.dart';

enum MessagesStatus { initial, loading, loaded, error }

class MessagesState extends Equatable {
  final MessagesStatus status;
  final List<Message> messages;
  final String? currentUserId;
  final bool isSending;
  final String? errorMessage;

  final String? snackBarMessage;
  final bool snackBarIsError;

  final bool shouldScrollToBottom;

  const MessagesState({
    this.status = MessagesStatus.initial,
    this.messages = const [],
    this.currentUserId,
    this.isSending = false,
    this.errorMessage,
    this.snackBarMessage,
    this.snackBarIsError = true,
    this.shouldScrollToBottom = false,
  });

  bool get isLoading => status == MessagesStatus.loading;
  bool get isLoaded => status == MessagesStatus.loaded;
  bool get isError => status == MessagesStatus.error;

  MessagesState copyWith({
    MessagesStatus? status,
    List<Message>? messages,
    String? currentUserId,
    bool? isSending,
    String? errorMessage,
    String? snackBarMessage,
    bool? snackBarIsError,
    bool? shouldScrollToBottom,
    bool clearError = false,
    bool clearSnackBar = false,
  }) {
    return MessagesState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      currentUserId: currentUserId ?? this.currentUserId,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      snackBarMessage:
          clearSnackBar ? null : (snackBarMessage ?? this.snackBarMessage),
      snackBarIsError: snackBarIsError ?? this.snackBarIsError,
      shouldScrollToBottom: shouldScrollToBottom ?? false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        currentUserId,
        isSending,
        errorMessage,
        snackBarMessage,
        snackBarIsError,
        shouldScrollToBottom,
      ];
}