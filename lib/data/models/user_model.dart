import 'package:eios/data/models/user_photo.dart';
import 'package:eios/data/models/user_role.dart';

class UserModel {
  final String? email;
  final bool? emailConfirmed;
  final String? englishFIO;
  final String? teacherCod;
  final String? studentCod;
  final String? birthDate;
  final String? academicDegree;
  final String? academicRank;
  final List<UserRole>? roles;
  final String? id;
  final String? userName;
  final String? fio;
  final UserPhoto? photo;

  UserModel({
    this.id,
    this.userName,
    this.fio,
    this.email,
    this.photo,
    this.roles,
    this.emailConfirmed,
    this.englishFIO,
    this.teacherCod,
    this.studentCod,
    this.birthDate,
    this.academicDegree,
    this.academicRank,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['Email'] as String?,
      emailConfirmed: json['EmailConfirmed'] as bool?,
      englishFIO: json['EnglishFIO'] as String?,
      teacherCod: json['TeacherCod'] as String?,
      studentCod: json['StudentCod'] as String?,
      birthDate: json['BirthDate'] as String?,
      academicDegree: json['AcademicDegree'] as String?,
      academicRank: json['AcademicRank'] as String?,
      roles:
          (json['Roles'] as List?)
              ?.map((role) => UserRole.fromJson(role as Map<String, dynamic>))
              .toList() ??
          [],
      id: json['Id'] as String?,
      fio: json['FIO'] as String?,
      photo: json['Photo'] != null
          ? UserPhoto.fromJson(json['Photo'] as Map<String, dynamic>)
          : null,
    );
  }
}
