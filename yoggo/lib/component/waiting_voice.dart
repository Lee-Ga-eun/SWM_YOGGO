import 'package:flutter/material.dart';
import './check_voice.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WaitingVoicePage extends StatefulWidget {
  const WaitingVoicePage({super.key});

  @override
  _WaitingVoicePageState createState() => _WaitingVoicePageState();
}

class _WaitingVoicePageState extends State<WaitingVoicePage>
    with TickerProviderStateMixin {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  //late AnimationController _controller;
  //double _progressValue = 0.0;
  late String token;
  String completeInferenced = '';

  @override
  void initState() {
    super.initState();
    //startTimer();
    getToken();
  }

  @override
  void dispose() {
    //_controller.dispose();
    super.dispose();
  }

  // void startTimer() {
  //   _controller = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 10),
  //   );

  //   _controller.addListener(() {
  //     setState(() {
  //       _progressValue = _controller.value;
  //     });
  //   });

  //   _controller.addStatusListener((status) {
  //     if (status == AnimationStatus.completed) {
  //       // 10초 후에 complete_voice.dart 페이지로 이동
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const CheckVoice(),
  //         ),
  //       );
  //     }
  //   });

  //   _controller.forward();
  // }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      inferenceResult(token);
    });
  }

  Future<void> inferenceResult(String token) async {
    while (true) {
      var response = await http.get(
        Uri.parse('https://yoggo-server.fly.dev/user/inference'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // 데이터를 성공적으로 받아온 경우
        var data = response.body;
        // 원하는 데이터를 처리하는 로직을 추가
        print(data);
        completeInferenced = json.decode(data)[0];
        break; // 데이터를 받아왔으므로 반복문 종료
      } else {
        // 데이터를 받아오지 못한 경우
        print('Failed to fetch data. Retrying in 1 second...');
        await Future.delayed(const Duration(seconds: 1)); // 1초간 대기 후 다시 요청
      }
    }
    await Future.delayed(Duration.zero);
    navigatorKey.currentState?.push(
      //context,
      MaterialPageRoute(
        builder: (context) => const CheckVoice(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  // value: _progressValue,
                  ),
              SizedBox(height: 20),
              Text(
                'Waiting for Voice...',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 5),
              Text(
                'Expecting 10s',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
