import 'package:eios/data/models/record_book.dart';
import 'package:eios/data/models/student_rating_plan.dart';
import 'package:eios/data/models/student_semestr.dart';

enum SemesterLoadStatus { loading, loaded, error }

class DisciplineListState {
  final SemesterLoadStatus semesterStatus;
  final bool isLoadingDisciplines;
  final bool isLoadingRatingPlan;

  final List<StudentSemestr> availableSemesters;
  final List<RecordBook> recordBooks;

  final String? selectedYear;
  final int? selectedPeriod;

  final String? snackBarMessage;

  final StudentRatingPlan? ratingPlanToNavigate;
  final String? ratingPlanDisciplineTitle;

  const DisciplineListState({
    this.semesterStatus = SemesterLoadStatus.loading,
    this.isLoadingDisciplines = false,
    this.isLoadingRatingPlan = false,
    this.availableSemesters = const [],
    this.recordBooks = const [],
    this.selectedYear,
    this.selectedPeriod,
    this.snackBarMessage,
    this.ratingPlanToNavigate,
    this.ratingPlanDisciplineTitle,
  });

  bool get isSemestersLoading => semesterStatus == SemesterLoadStatus.loading;
  bool get isSemestersLoaded => semesterStatus == SemesterLoadStatus.loaded;

  List<String?> get availableYears =>
      availableSemesters.map((e) => e.year).toSet().toList();

  List<int?> get availablePeriods => availableSemesters
      .where((e) => e.year == selectedYear)
      .map((e) => e.period)
      .toList();

  DisciplineListState copyWith({
    SemesterLoadStatus? semesterStatus,
    bool? isLoadingDisciplines,
    bool? isLoadingRatingPlan,
    List<StudentSemestr>? availableSemesters,
    List<RecordBook>? recordBooks,
    String? selectedYear,
    int? selectedPeriod,
    String? snackBarMessage,
    StudentRatingPlan? ratingPlanToNavigate,
    String? ratingPlanDisciplineTitle,
    bool clearSnackBar = false,
    bool clearNavigation = false,
  }) {
    return DisciplineListState(
      semesterStatus: semesterStatus ?? this.semesterStatus,
      isLoadingDisciplines: isLoadingDisciplines ?? this.isLoadingDisciplines,
      isLoadingRatingPlan: isLoadingRatingPlan ?? this.isLoadingRatingPlan,
      availableSemesters: availableSemesters ?? this.availableSemesters,
      recordBooks: recordBooks ?? this.recordBooks,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
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
