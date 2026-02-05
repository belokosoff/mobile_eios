class RatingMark {
  final int? id;
  final double? ball;
  final String? creatorId;
  final String? createDate;

  RatingMark({this.id, this.ball, this.creatorId, this.createDate});

  factory RatingMark.fromJson(Map<String, dynamic> json) => RatingMark(
        id: json['Id'],
        ball: (json['Ball'] as num?)?.toDouble(),
        creatorId: json['CreatorId'],
        createDate: json['CreateDate'],
      );
}