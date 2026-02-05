import 'package:eios/data/models/docfile.dart';

class ControlDotReport {
  final int? id;
  final String? createDate;
  final DocFile? docFile;

  ControlDotReport({this.id, this.createDate, this.docFile});

  factory ControlDotReport.fromJson(Map<String, dynamic> json) => ControlDotReport(
        id: json['Id'],
        createDate: json['CreateDate'],
        docFile: json['DocFile'] != null ? DocFile.fromJson(json['DocFile']) : null,
      );
}