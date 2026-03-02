import 'package:eios/data/models/accepted_attendance.dart';

enum AttendanceStatus { idle, loading, success, error }

class AttendanceState {
  final AttendanceStatus status;
  final bool isScannerLocked;
  final AcceptedAttendance? successResult;
  final String? errorMessage;

  const AttendanceState({
    this.status = AttendanceStatus.idle,
    this.isScannerLocked = false,
    this.successResult,
    this.errorMessage,
  });

  bool get isLoading => status == AttendanceStatus.loading;

  AttendanceState copyWith({
    AttendanceStatus? status,
    bool? isScannerLocked,
    AcceptedAttendance? successResult,
    String? errorMessage, 
    bool clearResult = false,
    bool clearError = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      isScannerLocked: isScannerLocked ?? this.isScannerLocked,
      successResult: clearResult ? null : (successResult ?? this.successResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
