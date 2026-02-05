class Auditorium {
  final int? id;
  final String? number;
  final String? title;
  final int? campusId;
  final String? campusTitle;

  Auditorium({
    this.id,
    this.number,
    this.title,
    this.campusId,
    this.campusTitle,
  });

  factory Auditorium.fromJson(Map<String, dynamic> json) {
    return Auditorium(
      id: json["Id"] is int
          ? json["Id"]
          : int.tryParse(json["Id"]?.toString() ?? ''),
      number: json["Number"]?.toString(),
      title: json["Title"]?.toString(),
      campusId: json["CampusId"] is int
          ? json["CampusId"]
          : int.tryParse(json["CampusId"]?.toString() ?? ''),
      campusTitle: json["CampusTitle"]?.toString(),
    );
  }
}
