import 'package:eios/data/models/time_table.dart';

class StudentTimeTable {
  final String? group;
  final String? planNumber;
  final String? facultyName;
  final int? timeTableBlockd;
  final TimeTable? timeTable;

  StudentTimeTable({
    this.group,
    this.planNumber,
    this.facultyName,
    this.timeTableBlockd,
    this.timeTable
  });

  factory StudentTimeTable.fromJson(Map<String, dynamic> json){
    return StudentTimeTable(
      group: json["Group"]?.toString(),
      planNumber: json["PlanNumber"]?.toString(),
      facultyName: json["FacultyName"]?.toString(),
      timeTableBlockd: json["TimeTableBlockd"] is int
          ? json["TimeTableBlockd"]
          : int.tryParse(json["TimeTableBlockd"]?.toString() ?? ''),
      timeTable: json['TimeTable'] != null
          ? TimeTable.fromJson(json['TimeTable'] as Map<String, dynamic>)
          : null,
    );
  }
}