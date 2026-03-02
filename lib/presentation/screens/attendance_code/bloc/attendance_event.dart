abstract class AttendanceEvent {}

class AttendanceCodeSubmitted extends AttendanceEvent {
  final String code;
  AttendanceCodeSubmitted(this.code);
}

class AttendanceResultHandled extends AttendanceEvent {}

class AttendanceScannerUnlocked extends AttendanceEvent {}
