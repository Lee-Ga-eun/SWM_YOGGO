class UserModel {
  String ?name;
  String ?email;
  final String providerId;
  final String provider;

  UserModel({
    this.name,
    this.email,
    required this.providerId,
    required this.provider,
  });

Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'providerId': providerId,
      'provider': provider,
    };
  }
}
