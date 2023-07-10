import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../component/check_voice.dart';

class WaitingVoicePage extends StatefulWidget {
  const WaitingVoicePage({super.key});

  @override
  _WaitingVoiceState createState() => _WaitingVoiceState();
}

class _WaitingVoiceState extends State<WaitingVoicePage> {
  bool isLoading = true;
  late String token;
  String completeInferenced = '';

  @override
  void initState() {
    super.initState();
    getToken();
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
    });
    loadData(token);
  }

  Future<void> loadData(String token) async {
    try {
      var response = await http.get(
        Uri.parse('https://yoggo-server.fly.dev/user/inference'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)[0];
        if (data != null && data.isNotEmpty) {
          // 데이터가 빈 값이 아닌 경우
          setState(() {
            isLoading = false;
            completeInferenced = data;
          });
        } else {
          // 데이터가 빈 값인 경우
          setState(() {
            isLoading = true;
            //loadData(token);
            Future.delayed(const Duration(seconds: 1), () {
              loadData(token);
            });
          });
        }
      } else {
        // 데이터 요청이 실패한 경우
        // 오류 처리
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // 네트워크 오류 등 예외 처리
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Waiting Voice'),
      //   backgroundColor: Colors.white.withOpacity(0),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CheckVoice(infenrencedVoice: completeInferenced),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check)),
        ),
      ),
    );
  }
}
// class WaitingVoicePage extends StatefulWidget {
//   const WaitingVoicePage({Key? key}) : super(key: key);

//   @override
//   _WaitingVoicePageState createState() => _WaitingVoicePageState();
// }

// class _WaitingVoicePageState extends State<WaitingVoicePage> {
//   late String token;
//   String completeInferenced = '';

//   @override
//   void initState() {
//     super.initState();
//     getToken();
//   }

//   Future<void> getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token')!;
//     });
//     inferenceResult(token);
//   }

//   inferenceResult(String token) async {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       while (completeInferenced.isEmpty) {
//         print("호출");
//         var response = await http.get(
//           Uri.parse('https://yoggo-server.fly.dev/user/inference'),
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//         );
//         var data = json.decode(response.body);
//         print("데이타 확인");
//         print(data);
//         if (data.isNotEmpty) {
//           setState(() {
//             completeInferenced = data[0];
//           });
//           break;
//         } else {
//           await Future.delayed(const Duration(seconds: 1));
//           //inferenceResult(token);
//         }
//       }
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               CheckVoice(infenrencedVoice: completeInferenced),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     inferenceResult(token);
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('lib/images/bkground.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text(
//                 'Waiting for Voice...',
//                 style: TextStyle(fontSize: 20),
//               ),
//               SizedBox(height: 5),
//               Text(
//                 'Expecting 10s',
//                 style: TextStyle(fontSize: 10),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


