import 'package:eios/data/models/auditorium.dart';
import 'package:eios/data/models/user_crop.dart';

class TimeTableLessonDiscipline {
  final int? id;
  final String? title;
  final String? language;
  final int? lessonType;
  final bool? remote;
  final String? group;
  final int? subgroupNumber;
  final UserCrop? teacher;
  final Auditorium? auditorium;

  TimeTableLessonDiscipline({
    this.id,
    this.title,
    this.language,
    this.lessonType,
    this.remote,
    this.group,
    this.subgroupNumber,
    this.teacher,
    this.auditorium,
  });

  factory TimeTableLessonDiscipline.fromJson(Map<String, dynamic> json) {
    return TimeTableLessonDiscipline(
      id: json["Id"] is int
          ? json["Id"]
          : int.tryParse(json["Id"]?.toString() ?? ''),
      title: json["Title"]?.toString(),
      language: json["Language"]?.toString(),
      lessonType: json["LessonType"] is int
          ? json["LessonType"]
          : int.tryParse(json["LessonType"]?.toString() ?? ''),
      remote: json["Remote"] as bool?,
      group: json["Group"]?.toString(),
      subgroupNumber: json["SubgroupNumber"] is int
          ? json["SubgroupNumber"]
          : int.tryParse(json["SubgroupNumber"]?.toString() ?? ''),
      teacher: json['Teacher'] != null
          ? UserCrop.fromJson(json['Teacher'] as Map<String, dynamic>)
          : null,
        auditorium: json["Auditorium"] != null ? Auditorium.fromJson(json["Auditorium"] as Map<String, dynamic>) : null,
    );
  }
}
