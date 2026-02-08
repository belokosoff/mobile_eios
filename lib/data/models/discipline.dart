import 'package:eios/data/models/docfile.dart';

class Discipline {
  final bool? relevance;
  final bool? isTeacher;
  final int? unreadedCount;
  final int? unreadedMessageCount;
  final List<String>? groups;
  final List<DocFile>? docFiles; 
  final DocFile? workingProgramm;
  final int? id;
  final String? planNumber;
  final String? year;
  final String? faculty;
  final String? educationForm;
  final String? educationLevel;
  final String? specialty;
  final String? specialtyCod;
  final String? profile;
  final String? periodString;
  final int? periodInt;
  final String? title;
  final String? language;

  Discipline({
    this.relevance,
    this.isTeacher,
    this.unreadedCount,
    this.unreadedMessageCount,
    this.groups,
    this.docFiles,
    this.workingProgramm,
    this.id,
    this.planNumber,
    this.year,
    this.faculty,
    this.educationForm,
    this.educationLevel,
    this.specialty,
    this.specialtyCod,
    this.profile,
    this.periodString,
    this.periodInt,
    this.title,
    this.language,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      relevance: json['Relevance'] as bool?,
      isTeacher: json['IsTeacher'] as bool?,
      unreadedCount: json['UnreadedCount'] as int?,
      unreadedMessageCount: json['UnreadedMessageCount'] as int?,
      groups: json['Groups'] != null 
          ? List<String>.from(json['Groups']) 
          : null,
      docFiles: json['DocFiles'] != null
          ? (json['DocFiles'] as List)
              .map((i) => DocFile.fromJson(i))
              .toList()
          : null,
      workingProgramm: json['WorkingProgramm'] != null
          ? DocFile.fromJson(json['WorkingProgramm'])
          : null,
      id: json['Id'] as int?,
      planNumber: json['PlanNumber'] as String?,
      year: json['Year'] as String?,
      faculty: json['Faculty'] as String?,
      educationForm: json['EducationForm'] as String?,
      educationLevel: json['EducationLevel'] as String?,
      specialty: json['Specialty'] as String?,
      specialtyCod: json['SpecialtyCod'] as String?,
      profile: json['Profile'] as String?,
      periodString: json['PeriodString'] as String?,
      periodInt: json['PeriodInt'] as int?,
      title: json['Title'] as String?,
      language: json['Language'] as String?,
    );
  }
}