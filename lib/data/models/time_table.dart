import 'package:eios/data/models/time_table_lessons.dart';

class TimeTable {
  final String? date;
  final List<TimeTableLesson>? lessons;

  TimeTable({
    this.date,
    this.lessons
  });

  factory TimeTable.fromJson(Map<String, dynamic> json){
    return TimeTable(
      date: json["Date"]?.toString(),
      lessons: (json['Lessons'] as List?)
              ?.map(
                (lesson) => TimeTableLesson.fromJson(
                  lesson as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}
