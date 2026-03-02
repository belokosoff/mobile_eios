import 'package:eios/data/models/student_rating_plan.dart';
import 'package:eios/data/models/student_time_table.dart';
import 'package:table_calendar/table_calendar.dart';

enum TimetableStatus { initial, loading, loaded, error }

class TimetableState {
  final TimetableStatus status;
  final List<StudentTimeTable>? timetableData;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final bool isLoadingRatingPlan;
  final String? snackBarMessage;

  final StudentRatingPlan? ratingPlanToNavigate;
  final String? ratingPlanDisciplineTitle;

  const TimetableState({
    this.status = TimetableStatus.initial,
    this.timetableData,
    required this.selectedDay,
    required this.focusedDay,
    this.calendarFormat = CalendarFormat.month,
    this.isLoadingRatingPlan = false,
    this.snackBarMessage,
    this.ratingPlanToNavigate,
    this.ratingPlanDisciplineTitle,
  });

  bool get isLoading => status == TimetableStatus.loading;

  TimetableState copyWith({
    TimetableStatus? status,
    List<StudentTimeTable>? timetableData,
    DateTime? selectedDay,
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
    bool? isLoadingRatingPlan,
    String? snackBarMessage,
    StudentRatingPlan? ratingPlanToNavigate,
    String? ratingPlanDisciplineTitle,
    bool clearSnackBar = false,
    bool clearNavigation = false,
    bool clearTimetable = false,
  }) {
    return TimetableState(
      status: status ?? this.status,
      timetableData: clearTimetable
          ? null
          : (timetableData ?? this.timetableData),
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
      isLoadingRatingPlan: isLoadingRatingPlan ?? this.isLoadingRatingPlan,
      snackBarMessage: clearSnackBar
          ? null
          : (snackBarMessage ?? this.snackBarMessage),
      ratingPlanToNavigate: clearNavigation
          ? null
          : (ratingPlanToNavigate ?? this.ratingPlanToNavigate),
      ratingPlanDisciplineTitle: clearNavigation
          ? null
          : (ratingPlanDisciplineTitle ?? this.ratingPlanDisciplineTitle),
    );
  }
}
