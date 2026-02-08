import 'package:eios/data/models/discipline.dart';

class RecordBook {
  final String? cod;
  final String? number;
  final String? faculty;
  final List<Discipline>? disciplines;

  RecordBook({this.cod, this.number, this.faculty, this.disciplines});

  factory RecordBook.fromJson(Map<String, dynamic> json) {
    return RecordBook(
      cod: json["Cod"],
      number: json["Number"],
      faculty: json["Faculty"],
      disciplines:
          (json['Disciplines'] as List?)
              ?.map(
                (discipline) =>
                    Discipline.fromJson(discipline as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  String get displayName {
    if (faculty != null && number != null) {
      return '$faculty (№$number)';
    }
    return faculty ?? number ?? 'Зачётная книжка';
  }

  int get relevantDisciplinesCount {
    return disciplines?.where((d) => d.relevance != false).length ?? 0;
  }
}
