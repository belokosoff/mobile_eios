import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eios/data/repositories/brs_repository.dart';
import 'package:eios/data/repositories/user_repository.dart';
import 'package:eios/core/exceptions/app_exceptions.dart';

import 'messages_event.dart';
import 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final int disciplineId;
  final BrsRepository _brsRepository;
  final UserRepository _userRepository;

  MessagesBloc({
    required this.disciplineId,
    BrsRepository? brsRepository,
    UserRepository? userRepository,
  })  : _brsRepository = brsRepository ?? BrsRepository(),
        _userRepository = userRepository ?? UserRepository(),
        super(const MessagesState()) {
    on<MessagesStarted>(_onStarted);
    on<MessagesRefreshed>(_onRefreshed);
    on<MessageSent>(_onSent);
    on<MessageDeleted>(_onDeleted);
    on<MessagesSnackBarDismissed>(_onSnackBarDismissed);
  }


  Future<String?> _resolveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedId = prefs.getString('user_id');
    debugPrint('DEBUG: SharedPreferences user_id = "$savedId"');

    if (savedId == null || savedId == '0' || savedId.isEmpty) {
      final profile = await _userRepository.getUserProfile();
      savedId = profile.id;
      debugPrint('DEBUG: Профиль user_id = "$savedId"');

      if (savedId != null && savedId != '0') {
        await prefs.setString('user_id', savedId);
      }
    }
    return savedId;
  }


  Future<List<dynamic>> _fetchSorted() async {
    final messages = await _brsRepository.getMessages(
      disciplineId: disciplineId,
    );

    messages.sort((a, b) {
      if (a.createDate == null || b.createDate == null) return 0;
      try {
        return DateTime.parse(a.createDate!)
            .compareTo(DateTime.parse(b.createDate!));
      } catch (_) {
        return 0;
      }
    });

    return messages;
  }


  Future<void> _onStarted(
    MessagesStarted event,
    Emitter<MessagesState> emit,
  ) async {
    emit(state.copyWith(status: MessagesStatus.loading, clearError: true));

    try {
      final results = await Future.wait([
        _resolveUserId(),
        _fetchSorted(),
      ]);

      final userId = results[0] as String?;
      final messages = results[1] as List;

      emit(state.copyWith(
        status: MessagesStatus.loaded,
        currentUserId: userId,
        messages: messages.cast(),
        shouldScrollToBottom: true,
      ));
    } on ForbiddenException {
      emit(state.copyWith(
        status: MessagesStatus.error,
        errorMessage: 'У вас нет доступа к этой дисциплине',
      ));
    } on NotFoundException {
      emit(state.copyWith(
        status: MessagesStatus.error,
        errorMessage: 'Дисциплина не найдена',
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        status: MessagesStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MessagesStatus.error,
        errorMessage: 'Произошла ошибка: $e',
      ));
    }
  }

  Future<void> _onRefreshed(
    MessagesRefreshed event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      final messages = await _fetchSorted();
      emit(state.copyWith(
        status: MessagesStatus.loaded,
        messages: messages.cast(),
        clearError: true,
        shouldScrollToBottom: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        snackBarMessage: 'Ошибка обновления: $e',
        snackBarIsError: true,
      ));
    }
  }

  Future<void> _onSent(
    MessageSent event,
    Emitter<MessagesState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) {
      emit(state.copyWith(
        snackBarMessage: 'Сообщение не может быть пустым',
        snackBarIsError: true,
      ));
      return;
    }

    emit(state.copyWith(isSending: true));

    try {
      await _brsRepository.sendMessage(
        disciplineId: disciplineId,
        messageText: text,
      );

      final messages = await _fetchSorted();

      emit(state.copyWith(
        isSending: false,
        messages: messages.cast(),
        shouldScrollToBottom: true,
      ));
    } on BadRequestException {
      emit(state.copyWith(
        isSending: false,
        snackBarMessage: 'Сообщение не должно быть пустым',
        snackBarIsError: true,
      ));
    } on ForbiddenException {
      emit(state.copyWith(
        isSending: false,
        snackBarMessage: 'У вас нет доступа к этой дисциплине',
        snackBarIsError: true,
      ));
    } on NotFoundException {
      emit(state.copyWith(
        isSending: false,
        snackBarMessage: 'Дисциплина не найдена',
        snackBarIsError: true,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        isSending: false,
        snackBarMessage: e.message,
        snackBarIsError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        snackBarMessage: 'Ошибка отправки: $e',
        snackBarIsError: true,
      ));
    }
  }

  Future<void> _onDeleted(
    MessageDeleted event,
    Emitter<MessagesState> emit,
  ) async {
    try {
      await _brsRepository.deleteMessage(id: event.messageId);
      final messages = await _fetchSorted();

      emit(state.copyWith(
        messages: messages.cast(),
        snackBarMessage: 'Сообщение удалено',
        snackBarIsError: false, // зелёный SnackBar
      ));
    } on ForbiddenException {
      emit(state.copyWith(
        snackBarMessage: 'Вы не можете удалить чужое сообщение',
        snackBarIsError: true,
      ));
    } on NotFoundException {
      emit(state.copyWith(
        snackBarMessage: 'Сообщение не найдено',
        snackBarIsError: true,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(
        snackBarMessage: e.message,
        snackBarIsError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        snackBarMessage: 'Ошибка удаления: $e',
        snackBarIsError: true,
      ));
    }
  }

  void _onSnackBarDismissed(
    MessagesSnackBarDismissed event,
    Emitter<MessagesState> emit,
  ) {
    emit(state.copyWith(clearSnackBar: true));
  }
}