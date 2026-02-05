import 'package:eios/data/models/control_dot_report.dart';
import 'package:eios/data/models/rating_mark.dart';
import 'package:eios/data/models/test_profile.dart';

class ControlDot {
  final int? id;
  final int? order;
  final String? title;
  final String? date;
  final double? maxBall;
  final bool? isReport;
  final bool? isCredit;
  final String? creatorId;
  final String? createDate;
  final RatingMark? mark;
  final ControlDotReport? report;
  final List<TestProfile>? testProfiles;

  ControlDot({
    this.id, this.order, this.title, this.date, this.maxBall,
    this.isReport, this.isCredit, this.creatorId, this.createDate,
    this.mark, this.report, this.testProfiles,
  });

  factory ControlDot.fromJson(Map<String, dynamic> json) => ControlDot(
        id: json['Id'],
        order: json['Order'],
        title: json['Title'],
        date: json['Date'],
        maxBall: (json['MaxBall'] as num?)?.toDouble(),
        isReport: json['IsReport'],
        isCredit: json['IsCredit'],
        creatorId: json['CreatorId'],
        createDate: json['CreateDate'],
        mark: json['Mark'] != null ? RatingMark.fromJson(json['Mark']) : null,
        report: json['Report'] != null ? ControlDotReport.fromJson(json['Report']) : null,
        testProfiles: (json['TestProfiles'] as List?)
            ?.map((e) => TestProfile.fromJson(e))
            .toList(),
      );
}