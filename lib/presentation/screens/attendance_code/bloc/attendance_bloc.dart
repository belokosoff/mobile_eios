import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eios/data/repositories/brs_repository.dart';

import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final BrsRepository _repository;

  AttendanceBloc({BrsRepository? repository})
    : _repository = repository ?? BrsRepository(),
      super(const AttendanceState()) {
    on<AttendanceCodeSubmitted>(_onCodeSubmitted);
    on<AttendanceResultHandled>(_onResultHandled);
    on<AttendanceScannerUnlocked>(_onScannerUnlocked);
  }

  Future<void> _onCodeSubmitted(
    AttendanceCodeSubmitted event,
    Emitter<AttendanceState> emit,
  ) async {
    final code = event.code.trim();
    if (code.isEmpty) {
      emit(
        state.copyWith(
          status: AttendanceStatus.error,
          errorMessage: 'Введите код',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AttendanceStatus.loading,
        isScannerLocked: true,
        clearResult: true,
        clearError: true,
      ),
    );

    try {
      final result = await _repository.sendStudentAttendanceCode(code: code);

      emit(
        state.copyWith(status: AttendanceStatus.success, successResult: result),
      );

      await Future.delayed(const Duration(seconds: 3));
      add(AttendanceScannerUnlocked());
    } catch (e) {
      emit(
        state.copyWith(
          status: AttendanceStatus.error,
          errorMessage: 'Ошибка: $e',
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      add(AttendanceScannerUnlocked());
    }
  }

  void _onResultHandled(
    AttendanceResultHandled event,
    Emitter<AttendanceState> emit,
  ) {
    emit(
      state.copyWith(
        status: AttendanceStatus.idle,
        clearResult: true,
        clearError: true,
      ),
    );
  }

  void _onScannerUnlocked(
    AttendanceScannerUnlocked event,
    Emitter<AttendanceState> emit,
  ) {
    emit(state.copyWith(isScannerLocked: false));
  }
}
