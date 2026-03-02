import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eios/data/repositories/timetable_repository.dart';

import 'timetable_event.dart';
import 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository _repository;

  TimetableBloc({TimetableRepository? repository})
    : _repository = repository ?? TimetableRepository(),
      super(
        TimetableState(selectedDay: DateTime.now(), focusedDay: DateTime.now()),
      ) {
    on<TimetableStarted>(_onStarted);
    on<TimetableDateSelected>(_onDateSelected);
    on<TimetableFormatChanged>(_onFormatChanged);
    on<TimetablePageChanged>(_onPageChanged);
    on<TimetableRatingPlanRequested>(_onRatingPlanRequested);
    on<TimetableSnackBarDismissed>(_onSnackBarDismissed);
    on<TimetableNavigationHandled>(_onNavigationHandled);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _onStarted(
    TimetableStarted event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(status: TimetableStatus.loading));

    try {
      final data = await _repository.getStudentTimeTable(
        date: _formatDate(state.selectedDay),
      );
      emit(state.copyWith(status: TimetableStatus.loaded, timetableData: data));
    } catch (e) {
      emit(
        state.copyWith(
          status: TimetableStatus.loaded,
          clearTimetable: true,
          snackBarMessage: 'Ошибка загрузки: $e',
        ),
      );
    }
  }

  Future<void> _onDateSelected(
    TimetableDateSelected event,
    Emitter<TimetableState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TimetableStatus.loading,
        selectedDay: event.selectedDay,
        focusedDay: event.focusedDay,
      ),
    );

    try {
      final data = await _repository.getStudentTimeTable(
        date: _formatDate(event.selectedDay),
      );
      emit(state.copyWith(status: TimetableStatus.loaded, timetableData: data));
    } catch (e) {
      emit(
        state.copyWith(
          status: TimetableStatus.loaded,
          clearTimetable: true,
          snackBarMessage: 'Ошибка загрузки: $e',
        ),
      );
    }
  }

  void _onFormatChanged(
    TimetableFormatChanged event,
    Emitter<TimetableState> emit,
  ) {
    emit(state.copyWith(calendarFormat: event.format));
  }

  void _onPageChanged(
    TimetablePageChanged event,
    Emitter<TimetableState> emit,
  ) {
    emit(state.copyWith(focusedDay: event.focusedDay));
  }

  Future<void> _onRatingPlanRequested(
    TimetableRatingPlanRequested event,
    Emitter<TimetableState> emit,
  ) async {
    final d = event.discipline;
    if (d.id == null) return;

    emit(state.copyWith(isLoadingRatingPlan: true));

    try {
      final ratingPlan = await _repository.getRatingPlan(d.id!);

      emit(
        state.copyWith(
          isLoadingRatingPlan: false,
          ratingPlanToNavigate: ratingPlan,
          ratingPlanDisciplineTitle: d.title ?? 'Дисциплина',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingRatingPlan: false,
          snackBarMessage: 'Не удалось загрузить план: $e',
        ),
      );
    }
  }

  void _onSnackBarDismissed(
    TimetableSnackBarDismissed event,
    Emitter<TimetableState> emit,
  ) {
    emit(state.copyWith(clearSnackBar: true));
  }

  void _onNavigationHandled(
    TimetableNavigationHandled event,
    Emitter<TimetableState> emit,
  ) {
    emit(state.copyWith(clearNavigation: true));
  }
}
