import 'package:eios/data/models/user_crop.dart';

class TestProfile {
  final int? id;
  final String? testTitle;
  final UserCrop? creator;

  TestProfile({this.id, this.testTitle, this.creator});

  factory TestProfile.fromJson(Map<String, dynamic> json) => TestProfile(
        id: json['Id'],
        testTitle: json['TestTitle'],
        creator: json['Creator'] != null ? UserCrop.fromJson(json['Creator']) : null,
      );
}