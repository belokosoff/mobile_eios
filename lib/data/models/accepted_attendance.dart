import 'package:eios/data/models/user_crop.dart';

class AcceptedAttendance {
  final String? disciplineId;
  final String? disciplineTitle;
  final String? date;
  final UserCrop? teacher;

  AcceptedAttendance({
    this.date, this.disciplineId, this.disciplineTitle, this.teacher
  });
  factory AcceptedAttendance.fromJson(Map<String, dynamic> json){
    return AcceptedAttendance(
      disciplineId: json["DisciplineId"],
      disciplineTitle: json["DisciplineTitle"],
      date: json["Date"],
      teacher: json['Teacher'] != null
          ? UserCrop.fromJson(json['Teacher'])
          : null,
    );
  }
}
