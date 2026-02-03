class UserPhoto {
  final String? urlSmall;
  final String? urlMedium;
  final String? urlSource;

  UserPhoto({
    this.urlSmall,
    this.urlMedium,
    this.urlSource,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      urlSmall: json['UrlSmall'] as String?,
      urlMedium: json['UrlMedium'] as String?,
      urlSource: json['UrlSource'] as String?,
    );
  }
}