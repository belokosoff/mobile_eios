import 'package:eios/data/models/time_table_lesson_discipline.dart';
import 'package:table_calendar/table_calendar.dart';

abstract class TimetableEvent {}

class TimetableStarted extends TimetableEvent {}

class TimetableDateSelected extends TimetableEvent {
  final DateTime selectedDay;
  final DateTime focusedDay;

  TimetableDateSelected({required this.selectedDay, required this.focusedDay});
}

class TimetableFormatChanged extends TimetableEvent {
  final CalendarFormat format;
  TimetableFormatChanged(this.format);
}

class TimetablePageChanged extends TimetableEvent {
  final DateTime focusedDay;
  TimetablePageChanged(this.focusedDay);
}

class TimetableRatingPlanRequested extends TimetableEvent {
  final TimeTableLessonDiscipline discipline;
  TimetableRatingPlanRequested(this.discipline);
}

class TimetableSnackBarDismissed extends TimetableEvent {}

class TimetableNavigationHandled extends TimetableEvent {}
