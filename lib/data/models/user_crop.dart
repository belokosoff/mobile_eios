import 'package:eios/data/models/user_photo.dart';

class UserCrop {
  final String? id;
  final String? userName;
  final String? fio;
  final UserPhoto? photo;

  UserCrop({
    this.id,
    this.userName,
    this.fio,
    this.photo
  });

  factory UserCrop.fromJson(Map<String, dynamic> json){
    return UserCrop(
      id: json["Id"].toString(),
      userName: json["UserName"].toString(),
      fio: json["FIO"].toString(),
      photo: json['Photo'] != null
          ? UserPhoto.fromJson(json['Photo'] as Map<String, dynamic>)
          : null,
    );
  }
}