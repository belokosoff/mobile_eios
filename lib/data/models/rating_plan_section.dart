import 'package:eios/data/models/control_dot.dart';

class RatingPlanSection {
  final int? id;
  final int? order;
  final int sectionType; // 10, 20, 30, 40
  final String? title;
  final String? description;
  final String? creatorId;
  final String? createDate;
  final List<ControlDot>? controlDots;

  RatingPlanSection({
    this.id, this.order, required this.sectionType, this.title,
    this.description, this.creatorId, this.createDate, this.controlDots,
  });

  factory RatingPlanSection.fromJson(Map<String, dynamic> json) => RatingPlanSection(
        id: json['Id'],
        order: json['Order'],
        sectionType: json['SectionType'] ?? 10,
        title: json['Title'],
        description: json['Description'],
        creatorId: json['CreatorId'],
        createDate: json['CreateDate'],
        controlDots: (json['ControlDots'] as List?)
            ?.map((e) => ControlDot.fromJson(e))
            .toList(),
      );
}
