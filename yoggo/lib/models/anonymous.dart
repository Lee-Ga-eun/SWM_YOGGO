class AnonymousUserModel {
  final String anonymousId;

  AnonymousUserModel({
    required this.anonymousId,
  });

  Map<String, dynamic> toJson() {
    return {
      'anonymousId': anonymousId,
    };
  }
}
