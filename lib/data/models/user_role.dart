class UserRole {
  final String? name;
  final String? description;

  UserRole ({
    this.name,
    this.description,
  });

  factory UserRole.fromJson(Map<String, dynamic> json){
    return UserRole(
      name: json['Name'] as String?,
      description: json['Description'] as String?
    );
  }
}