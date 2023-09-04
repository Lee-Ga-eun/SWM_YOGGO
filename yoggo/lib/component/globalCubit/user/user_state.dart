class UserState {
  final int userId;
  final String userName;
  final String email;
  final bool record;
  final bool purchase;
  final bool login;
  final int point;
  int? voiceId;
  String? voiceName;
  String? voiceIcon;
  String? inferenceUrl;
  bool isDataFetched;

  UserState({
    required this.userId,
    required this.userName,
    required this.email,
    required this.record,
    required this.purchase,
    required this.login,
    required this.point,
    required this.isDataFetched,
    this.voiceId,
    this.voiceName,
    this.voiceIcon,
    this.inferenceUrl,
  });

  UserState copyWith({
    int? userId,
    String? userName,
    String? email,
    bool? record,
    bool? purchase,
    bool? isDataFetched,
    bool? login,
    int? point,
    int? voiceId,
    String? voiceName,
    String? voiceIcon,
    String? inferenceUrl,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      record: record ?? this.record,
      purchase: purchase ?? this.purchase,
      login: login ?? this.login,
      point: point ?? this.point,
      isDataFetched: isDataFetched ?? this.isDataFetched,
      voiceId: voiceId ?? this.voiceId,
      voiceIcon: voiceIcon ?? this.voiceIcon,
      voiceName: voiceName ?? this.voiceName,
      inferenceUrl: inferenceUrl ?? this.inferenceUrl,
    );
  }
}
