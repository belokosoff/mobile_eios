import 'package:eios/data/models/time_table_lesson_discipline.dart';

class TimeTableLesson {
  final int? number;
  final int? subgroupCount;
  final List<TimeTableLessonDiscipline>? disciplines;

  TimeTableLesson({this.number, this.subgroupCount, this.disciplines});

  factory TimeTableLesson.fromJson(Map<String, dynamic> json) {
    return TimeTableLesson(
      number: json["Number"] is int
          ? json["Number"]
          : int.tryParse(json["Number"]?.toString() ?? ''),
      subgroupCount: json["Id"] is int
          ? json["SubgroupCount"]
          : int.tryParse(json["SubgroupCount"]?.toString() ?? ''),
      disciplines:
          (json['Disciplines'] as List?)
              ?.map(
                (discipline) => TimeTableLessonDiscipline.fromJson(
                  discipline as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}
