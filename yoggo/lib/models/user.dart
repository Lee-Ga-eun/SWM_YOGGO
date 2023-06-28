class UserModel {
  final String name;
  final String email;
  final String providerId;
  final String provider;

  UserModel({
    required this.name,
    required this.email,
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
