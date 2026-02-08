import 'package:eios/data/models/record_book.dart';

class StudentSemestrWithDisciplines {
  final List<RecordBook>? recordBooks;
  final int? unreadedDisCount; 
  final int? unreadedDisMesCount;
  final String? year;
  final int? period;

   StudentSemestrWithDisciplines({
    this.recordBooks, this.unreadedDisCount, this.unreadedDisMesCount, this.year, this.period
   });

   factory StudentSemestrWithDisciplines.fromJson(Map<String, dynamic> json){
    return StudentSemestrWithDisciplines(
      recordBooks: (json['RecordBooks'] as List?)
              ?.map(
                (recordBook) => RecordBook.fromJson(
                  recordBook as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      unreadedDisCount: json['UnreadedDisCount'] as int?,
      unreadedDisMesCount: json['UnreadedDisMesCount'] as int?,
      year: json["Year"],
      period: json['Period'] as int?,
    );
   }
}