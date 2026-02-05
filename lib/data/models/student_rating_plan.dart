import 'package:eios/data/models/rating_mark.dart';
import 'package:eios/data/models/rating_plan_section.dart';

class StudentRatingPlan {
  final RatingMark? markZeroSession;
  final List<RatingPlanSection>? sections;

  StudentRatingPlan({this.markZeroSession, this.sections});

  factory StudentRatingPlan.fromJson(Map<String, dynamic> json) => StudentRatingPlan(
        markZeroSession: json['MarkZeroSession'] != null 
            ? RatingMark.fromJson(json['MarkZeroSession']) 
            : null,
        sections: (json['Sections'] as List?)
            ?.map((e) => RatingPlanSection.fromJson(e))
            .toList(),
      );
}