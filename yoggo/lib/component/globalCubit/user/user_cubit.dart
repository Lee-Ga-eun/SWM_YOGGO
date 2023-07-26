import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

late String token;
bool purchase = false;
bool record = false;

class UserCubit extends Cubit<UserState> {
  UserCubit()
      : super(UserState(
            userName: '',
            email: '',
            record: false,
            purchase: false,
            isDataFetched: false)) {
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      var url = Uri.parse('https://yoggo-server.fly.dev/user/myInfo');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        // API 응답 데이터 파싱
        final data = json.decode(response.body)[0];

        final userName = data['name'];

        final email = data['email'];

        final purchase = data['purchase'] as bool;

        final record = data['record'] as bool;
        const isDataFetched = true;
        if (record) {
          final voiceId = data['voiceId'];
          final voiceName = data['voiceName'];
          final voiceIcon = data['voiceIcon'];
          emit(UserState(
              userName: userName,
              email: email,
              purchase: purchase,
              record: record,
              isDataFetched: isDataFetched,
              voiceId: voiceId,
              voiceName: voiceName,
              voiceIcon: voiceIcon));
        }
        // 상태 업데이트
        else {
          emit(
            UserState(
                userName: userName,
                email: email,
                purchase: purchase,
                record: record,
                isDataFetched: isDataFetched),
          );
        }
        // emit(state.copyWith(
        //   userName: userName,
        //   email: email,
        //   record: record,
        //   purchase: purchase,
        // ));
        // // 한번 불러온 거 저장되도록 한다
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString('userName', userName);
        // prefs.setString('email', email);
        // prefs.setBool('purchase', purchase);
        // prefs.setBool('record', record);

        // final globalCubit = GlobalCubit();
        //globalCubit.updateUser(userName, email, record, purchase, true);
      } else {
        // API 호출 실패 시 에러 처리
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      // 예외 처리
      print('Error while fetching user data: $e');
    }
  }

  Future<void> login(String username, String email, bool record, bool purchase,
      bool isDataFetched) {
    emit(
      UserState(
          userName: username,
          email: email,
          purchase: purchase,
          record: record,
          isDataFetched: true),
    );
    return Future.value();
  }
}


// class UserCubit extends Cubit<UserState> {
//   UserCubit()
//       : super(UserState(
//             userName: '',
//             email: '',
//             record: false,
//             purchase: false,
//             isDataFetched: false));

//   Future<void> fetchUser() async {
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('token');

//       var url = Uri.parse('https://yoggo-server.fly.dev/user/myInfo');
//       var response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//       if (response.statusCode == 200) {
//         // API 응답 데이터 파싱
//         final data = json.decode(response.body)[0];
//         final userName = data['name'];
//         final email = data['email'];
//         purchase = data['purhcase'];
//         record = data['record'];
//         const isDataFetched = true;

//         // 상태 업데이트
//         // emit(
//         //   UserState(
//         //       userName: userName,
//         //       email: email,
//         //       purchase: purchase,
//         //       record: record,
//         //       isDataFetched: isDataFetched),
//         // );
//         emit(state.copyWith(
//           userName: userName,
//           email: email,
//           record: record,
//           purchase: purchase,
//         ));
//         // 한번 불러온 거 저장되도록 한다
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString('userName', userName);
//         prefs.setString('email', email);
//         prefs.setBool('purchase', purchase);
//         prefs.setBool('record', record);

//         // final globalCubit = GlobalCubit();
//         //globalCubit.updateUser(userName, email, record, purchase, true);
//       } else {
//         // API 호출 실패 시 에러 처리
//         print('Failed to fetch user data: ${response.statusCode}');
//       }
//     } catch (e) {
//       // 예외 처리
//       print('Error while fetching user data: $e');
//     }
//   }
//}
