import 'package:eios/data/models/user_crop.dart';

class Message {
  final int? id;
  final UserCrop? user;
  final bool? isTeacher;
  final String? createDate;
  final String? text;

  Message({
    this.id, this.user, this.isTeacher, this.createDate, this.text
  });

  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      id: json["Id"] as int?,
      user: json['User'] != null ? UserCrop.fromJson(json['User']) : null,
      isTeacher: json["IsTeacher"] as bool?,
      createDate: json["CreateDate"] as String?,
      text: json["Text"] as String?
    );
  }
}