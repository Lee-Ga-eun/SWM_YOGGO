class UserState {
  final String userName;
  final String email;
  final bool record;
  final bool purchase;
  bool isDataFetched;

  UserState({
    required this.userName,
    required this.email,
    required this.record,
    required this.purchase,
    required this.isDataFetched,
  });

  UserState copyWith({
    String? userName,
    String? email,
    bool? record,
    bool? purchase,
    bool? isDataFetched,
  }) {
    return UserState(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      record: record ?? this.record,
      purchase: purchase ?? this.purchase,
      isDataFetched: isDataFetched ?? this.isDataFetched,
    );
  }
}
