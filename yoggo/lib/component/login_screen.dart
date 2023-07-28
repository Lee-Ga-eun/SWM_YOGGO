import 'dart:convert';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/models/user.dart';
import 'package:yoggo/size_config.dart';
import '../component/globalCubit/user/user_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late UserCubit userCubit;

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    userCubit = context.read<UserCubit>();
    //userCubit = context.watch<UserCubit>(listen: false);

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      UserModel user = UserModel(
        //name: googleUser.displayName!,
        //email: googleUser.email,
        //providerId: googleUser.id,
        idToken: googleAuth.idToken!,
        provider: 'google',
      );

      //googleUser.authentication.accessToken을 넘겨라 -> verify를 google에 해라. -> token을 다시 넘겨줘라
      var url = Uri.parse('https://yoggo-server.fly.dev/auth/login');
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(user.toJson()));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 로그인 성공
        var responseData = json.decode(response.body);
        var token = responseData['token'];
        var purchase = responseData['purchase'];
        var record = responseData['record'];
        var username = responseData['username'];
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setBool('purchase', purchase);
        await prefs.setBool('record', record);
        await prefs.setString('username', username);

        // await Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => const HomeScreen()));
        //print(username); 기존 코드
        //await userCubit.login(username, 'email', purchase, record, false);
        await userCubit.fetchUser();
        final state = userCubit.state;
        if (state.isDataFetched) {
          OneSignal.shared.setExternalUserId(state.userId.toString());
          Navigator.of(context).pop();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => const Purchase()), //HomeScreen()),
          // );
        }
      } else {
        // 로그인 실패
        print('로그인 실패. 상태 코드: ${response.statusCode}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    _sendLoginViewEvent();
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'lib/images/bkground.png', // 배경 이미지 파일 경로 (PNG 형식)
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('LOVEL', // 원하는 텍스트를 여기에 입력하세요
                      style: TextStyle(
                        fontSize: 10 * SizeConfig.defaultSize!,
                        color: Colors.black,
                        fontFamily: 'modak',
                      )),
                  SizedBox(height: 0 * SizeConfig.defaultSize!),
                  Text(
                    'Unlimited linkage between devices\nthrough your account', // 원하는 텍스트를 여기에 입력하세요
                    style: TextStyle(
                      fontSize: 2.5 * SizeConfig.defaultSize!,
                      color: Colors.black,
                      fontFamily: 'molengo',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4 * SizeConfig.defaultSize!),
                  InkWell(
                    onTap: () {
                      _sendLoginGoogleClickEvent();
                      signInWithGoogle(context);
                    },
                    child: Image.asset(
                      'lib/images/login_google.png', // 로그인 버튼 이미지 파일 경로 (PNG 형식)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _sendLoginViewEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'login_view',
        //parameters: <String, dynamic>{'contentId': contentId},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  static Future<void> _sendLoginGoogleClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'login_google_click',
        //parameters: <String, dynamic>{'contentId': contentId},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  static Future<void> _sendLoginAppleClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'login_apple_click',
        //parameters: <String, dynamic>{'contentId': contentId},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
