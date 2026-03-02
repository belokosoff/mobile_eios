import 'package:eios/data/models/discipline.dart';

abstract class DisciplineListEvent {}

class DisciplineListStarted extends DisciplineListEvent {}

class DisciplineListYearChanged extends DisciplineListEvent {
  final String year;
  DisciplineListYearChanged(this.year);
}

class DisciplineListPeriodChanged extends DisciplineListEvent {
  final int period;
  DisciplineListPeriodChanged(this.period);
}

class DisciplineListRefreshed extends DisciplineListEvent {}

class DisciplineListRatingPlanRequested extends DisciplineListEvent {
  final Discipline discipline;
  DisciplineListRatingPlanRequested(this.discipline);
}

class DisciplineListSnackBarDismissed extends DisciplineListEvent {}

class DisciplineListNavigationHandled extends DisciplineListEvent {}
