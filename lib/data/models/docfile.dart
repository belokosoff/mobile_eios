class DocFile {
  final String? id;
  final String creatorId;
  final String? title;
  final String fileName;
  final String? mimeType;
  final int? size;
  final String date;
  final String? url;

  DocFile({
    this.id,
    required this.creatorId,
    this.title,
    required this.fileName,
    this.mimeType,
    this.size,
    required this.date,
    this.url,
  });

  factory DocFile.fromJson(Map<String, dynamic> json) => DocFile(
        id: json['Id'],
        creatorId: json['CreatorId'] ?? '',
        title: json['Title'],
        fileName: json['FileName'] ?? '',
        mimeType: json['MIMEtype'],
        size: json['Size'],
        date: json['Date'] ?? '',
        url: json['URL'],
      );
}