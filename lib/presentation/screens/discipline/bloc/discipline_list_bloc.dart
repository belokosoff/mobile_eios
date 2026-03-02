import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eios/data/models/record_book.dart';
import 'package:eios/data/repositories/brs_repository.dart';
import 'package:eios/data/repositories/timetable_repository.dart';

import 'discipline_list_event.dart';
import 'discipline_list_state.dart';

class DisciplineListBloc
    extends Bloc<DisciplineListEvent, DisciplineListState> {
  final BrsRepository _brsRepository;
  final TimetableRepository _timetableRepository;

  static const _prefKeyYear = 'selected_year';
  static const _prefKeyPeriod = 'selected_period';
  static const _defaultYear = '2025 - 2026';
  static const _defaultPeriod = 2;

  DisciplineListBloc({
    BrsRepository? brsRepository,
    TimetableRepository? timetableRepository,
  }) : _brsRepository = brsRepository ?? BrsRepository(),
       _timetableRepository = timetableRepository ?? TimetableRepository(),
       super(const DisciplineListState()) {
    on<DisciplineListStarted>(_onStarted);
    on<DisciplineListYearChanged>(_onYearChanged);
    on<DisciplineListPeriodChanged>(_onPeriodChanged);
    on<DisciplineListRefreshed>(_onRefreshed);
    on<DisciplineListRatingPlanRequested>(_onRatingPlanRequested);
    on<DisciplineListSnackBarDismissed>(_onSnackBarDismissed);
    on<DisciplineListNavigationHandled>(_onNavigationHandled);
  }

  // ─── Helpers ───

  Future<void> _saveSelection(String? year, int? period) async {
    final prefs = await SharedPreferences.getInstance();
    if (year != null) await prefs.setString(_prefKeyYear, year);
    if (period != null) await prefs.setInt(_prefKeyPeriod, period);
  }

  Future<List<RecordBook>> _fetchDisciplines(String year, int period) async {
    final result = await _brsRepository.getDisciplinesBySemester(
      year: year,
      period: period,
    );

    return result.recordBooks
            ?.map(
              (rb) => RecordBook(
                cod: rb.cod,
                number: rb.number,
                faculty: rb.faculty,
                disciplines: rb.disciplines
                    ?.where((d) => d.relevance != false)
                    .toList(),
              ),
            )
            .where((rb) => rb.disciplines?.isNotEmpty ?? false)
            .toList() ??
        [];
  }

  Future<void> _onStarted(
    DisciplineListStarted event,
    Emitter<DisciplineListState> emit,  
  ) async {
    emit(state.copyWith(semesterStatus: SemesterLoadStatus.loading));

    try {
      final data = await _brsRepository.getStudentSemestr();
      if (data.isEmpty) {
        emit(
          state.copyWith(
            semesterStatus: SemesterLoadStatus.loaded,
            availableSemesters: [],
          ),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final savedYear = prefs.getString(_prefKeyYear);
      final savedPeriod = prefs.getInt(_prefKeyPeriod);

      final years = data.map((e) => e.year).toSet().toList();

      String? resolvedYear;
      if (savedYear != null && years.contains(savedYear)) {
        resolvedYear = savedYear;
      } else if (years.contains(_defaultYear)) {
        resolvedYear = _defaultYear;
      } else {
        resolvedYear = years.first;
      }

      final periods = data
          .where((e) => e.year == resolvedYear)
          .map((e) => e.period)
          .toList();

      int? resolvedPeriod;
      if (savedPeriod != null && periods.contains(savedPeriod)) {
        resolvedPeriod = savedPeriod;
      } else if (periods.contains(_defaultPeriod)) {
        resolvedPeriod = _defaultPeriod;
      } else {
        resolvedPeriod = periods.isNotEmpty ? periods.first : null;
      }

      emit(
        state.copyWith(
          semesterStatus: SemesterLoadStatus.loaded,
          availableSemesters: data,
          selectedYear: resolvedYear,
          selectedPeriod: resolvedPeriod,
        ),
      );

      await _saveSelection(resolvedYear, resolvedPeriod);

      if (resolvedYear != null && resolvedPeriod != null) {
        emit(state.copyWith(isLoadingDisciplines: true));
        try {
          final books = await _fetchDisciplines(resolvedYear, resolvedPeriod);
          emit(state.copyWith(isLoadingDisciplines: false, recordBooks: books));
        } catch (e) {
          emit(
            state.copyWith(
              isLoadingDisciplines: false,
              snackBarMessage: 'Ошибка загрузки дисциплин: $e',
            ),
          );
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          semesterStatus: SemesterLoadStatus.loaded,
          snackBarMessage: 'Ошибка загрузки семестров: $e',
        ),
      );
    }
  }

  Future<void> _onYearChanged(
    DisciplineListYearChanged event,
    Emitter<DisciplineListState> emit,
  ) async {
    final newPeriods = state.availableSemesters
        .where((e) => e.year == event.year)
        .map((e) => e.period)
        .toList();

    int? newPeriod = state.selectedPeriod;
    if (!newPeriods.contains(newPeriod)) {
      newPeriod = newPeriods.isNotEmpty ? newPeriods.first : null;
    }

    emit(
      state.copyWith(
        selectedYear: event.year,
        selectedPeriod: newPeriod,
        isLoadingDisciplines: true,
      ),
    );

    await _saveSelection(event.year, newPeriod);

    if (newPeriod != null) {
      try {
        final books = await _fetchDisciplines(event.year, newPeriod);
        emit(state.copyWith(isLoadingDisciplines: false, recordBooks: books));
      } catch (e) {
        emit(
          state.copyWith(
            isLoadingDisciplines: false,
            snackBarMessage: 'Ошибка загрузки дисциплин: $e',
          ),
        );
      }
    } else {
      emit(state.copyWith(isLoadingDisciplines: false, recordBooks: []));
    }
  }

  Future<void> _onPeriodChanged(
    DisciplineListPeriodChanged event,
    Emitter<DisciplineListState> emit,
  ) async {
    emit(
      state.copyWith(selectedPeriod: event.period, isLoadingDisciplines: true),
    );

    await _saveSelection(state.selectedYear, event.period);

    if (state.selectedYear != null) {
      try {
        final books = await _fetchDisciplines(
          state.selectedYear!,
          event.period,
        );
        emit(state.copyWith(isLoadingDisciplines: false, recordBooks: books));
      } catch (e) {
        emit(
          state.copyWith(
            isLoadingDisciplines: false,
            snackBarMessage: 'Ошибка загрузки дисциплин: $e',
          ),
        );
      }
    }
  }

  Future<void> _onRefreshed(
    DisciplineListRefreshed event,
    Emitter<DisciplineListState> emit,
  ) async {
    if (state.selectedYear == null || state.selectedPeriod == null) return;

    emit(state.copyWith(isLoadingDisciplines: true));

    try {
      final books = await _fetchDisciplines(
        state.selectedYear!,
        state.selectedPeriod!,
      );
      emit(state.copyWith(isLoadingDisciplines: false, recordBooks: books));
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingDisciplines: false,
          snackBarMessage: 'Ошибка загрузки дисциплин: $e',
        ),
      );
    }
  }

  Future<void> _onRatingPlanRequested(
    DisciplineListRatingPlanRequested event,
    Emitter<DisciplineListState> emit,
  ) async {
    final id = event.discipline.id;
    if (id == null) {
      emit(state.copyWith(snackBarMessage: 'Ошибка: ID дисциплины не найден'));
      return;
    }

    emit(state.copyWith(isLoadingRatingPlan: true));

    try {
      final plan = await _timetableRepository
          .getRatingPlan(id)
          .timeout(const Duration(seconds: 15));

      emit(
        state.copyWith(
          isLoadingRatingPlan: false,
          ratingPlanToNavigate: plan,
          ratingPlanDisciplineTitle: event.discipline.title ?? 'Дисциплина',
        ),
      );
    } catch (e) {
      String msg = 'Не удалось загрузить план: $e';
      if (e.toString().contains('TimeoutException')) {
        msg = 'Превышено время ожидания. Проверьте интернет.';
      }

      emit(state.copyWith(isLoadingRatingPlan: false, snackBarMessage: msg));
    }
  }

  void _onSnackBarDismissed(
    DisciplineListSnackBarDismissed event,
    Emitter<DisciplineListState> emit,
  ) {
    emit(state.copyWith(clearSnackBar: true));
  }

  void _onNavigationHandled(
    DisciplineListNavigationHandled event,
    Emitter<DisciplineListState> emit,
  ) {
    emit(state.copyWith(clearNavigation: true));
  }
}
