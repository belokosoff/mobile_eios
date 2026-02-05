class StudentSemestr {
  final String? year;
  final int? period;
  final int? unreadedDisCount;
  final int? unreadedDisMesCount;

  StudentSemestr({
    this.year,
    this.period,
    this.unreadedDisCount,
    this.unreadedDisMesCount,
  });

  factory StudentSemestr.fromJson(Map<String, dynamic> json) {
    return StudentSemestr(
      year: json["Year"]?.toString(),
      period: json["Period"] is int
          ? json["Period"]
          : int.tryParse(json["Period"]?.toString() ?? ''),
      unreadedDisCount: json["UnreadedDisCount"] is int
          ? json["UnreadedDisCount"]
          : int.tryParse(json["UnreadedDisCount"]?.toString() ?? ''),
      unreadedDisMesCount: json["UnreadedDisMesCount"] is int
          ? json["UnreadedDisMesCount"]
          : int.tryParse(json["UnreadedDisMesCount"]?.toString() ?? ''),
    );
  }
}
