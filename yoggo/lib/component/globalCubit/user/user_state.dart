class UserState {
  final String userName;
  final String email;
  final bool record;
  final bool purchase;
  int? voiceId;
  String? voiceName;
  String? voiceIcon;
  String? inferenceUrl;
  bool isDataFetched;

  UserState({
    required this.userName,
    required this.email,
    required this.record,
    required this.purchase,
    required this.isDataFetched,
    this.voiceId,
    this.voiceName,
    this.voiceIcon,
    this.inferenceUrl,
  });

  UserState copyWith({
    String? userName,
    String? email,
    bool? record,
    bool? purchase,
    bool? isDataFetched,
    int? voiceId,
    String? voiceName,
    String? voiceIcon,
    String? inferenceUrl,
  }) {
    return UserState(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      record: record ?? this.record,
      purchase: purchase ?? this.purchase,
      isDataFetched: isDataFetched ?? this.isDataFetched,
      voiceId: voiceId ?? this.voiceId,
      voiceIcon: voiceIcon ?? this.voiceIcon,
      voiceName: voiceName ?? this.voiceName,
      inferenceUrl: inferenceUrl ?? this.inferenceUrl,
    );
  }
}
