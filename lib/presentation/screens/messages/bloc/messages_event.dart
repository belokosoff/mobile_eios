import 'package:equatable/equatable.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

class MessagesStarted extends MessagesEvent {
  const MessagesStarted();
}

class MessagesRefreshed extends MessagesEvent {
  const MessagesRefreshed();
}

class MessageSent extends MessagesEvent {
  final String text;

  const MessageSent(this.text);

  @override
  List<Object?> get props => [text];
}

class MessageDeleted extends MessagesEvent {
  final int messageId;

  const MessageDeleted(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class MessagesSnackBarDismissed extends MessagesEvent {
  const MessagesSnackBarDismissed();
}