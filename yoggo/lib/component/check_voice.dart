import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/size_config.dart';
import 'globalCubit/user/user_cubit.dart';
import 'home/view/home_screen.dart';
import './record_retry.dart';
import 'package:audioplayers/audioplayers.dart';

class CheckVoice extends StatefulWidget {
  // final String infenrencedVoice;

  const CheckVoice({
    super.key,
    // required this.infenrencedVoice,
  });

  @override
  _CheckVoiceState createState() => _CheckVoiceState();
}

class _CheckVoiceState extends State<CheckVoice> {
  AudioPlayer audioPlayer = AudioPlayer();
  late String token;
  late String inferenceUrl = "";
  // void playAudio(String audioUrl) async {
  //   await audioPlayer.play(UrlSource(audioUrl));
  // }
  void initState() {
    super.initState();
    getToken();
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      getVoiceInfo(token);
    });
  }

  Future<void> getVoiceInfo(String token) async {
    var response = await http.get(
      Uri.parse('https://yoggo-server.fly.dev/user/inference'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != [] && data.isNotEmpty) {
        // 데이터가 빈 값이 아닌 경우
        setState(() {
          inferenceUrl = data[0];
        });
      }
    }
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    _sendVoiceViewEvent(
        userState.purchase, userState.record, userState.voiceId!);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          minimum: EdgeInsets.only(left: 9 * SizeConfig.defaultSize!),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'LOVEL',
                          style: TextStyle(
                            fontFamily: 'Modak',
                            fontSize: SizeConfig.defaultSize! * 5,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 2 * SizeConfig.defaultSize!,
                      child: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () {
                          audioPlayer.stop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        //color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded(
              //   flex: 1,
              //   child: Text(
              //     'Complete! Here is your voice!',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: 3 * SizeConfig.defaultSize!,
              //       color: const Color.fromARGB(255, 194, 120, 209),
              //       fontFamily: 'BreeSerif',
              //     ),
              //   ),
              // ),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    // SizedBox(
                    //   width: SizeConfig.defaultSize!,
                    // ),
                    Column(
                      children: [
                        Container(
                          width: 18 * SizeConfig.defaultSize!,
                          height: 18 * SizeConfig.defaultSize!,
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          decoration: ShapeDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Column(children: [
                            SizedBox(
                              height: SizeConfig.defaultSize! * 2.2,
                            ),
                            Image.asset(
                              'lib/images/icons/${userState.voiceIcon}-c.png',
                              height: SizeConfig.defaultSize! * 13.5,
                            ),
                          ]),
                        ),
                        SizedBox(
                          height: SizeConfig.defaultSize!,
                        ),
                        Container(
                            width: 18 * SizeConfig.defaultSize!,
                            height: 7.5 * SizeConfig.defaultSize!,
                            decoration: ShapeDecoration(
                              color: Colors.white.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Center(
                                child: Text(
                              userState.voiceName!,
                              style: TextStyle(
                                fontFamily: 'Molengo',
                                fontSize: SizeConfig.defaultSize! * 2.3,
                              ),
                            )))
                      ],
                    ),
                    SizedBox(
                      width: SizeConfig.defaultSize! * 2,
                    ),
                    Column(children: [
                      Container(
                        width: 52.4 * SizeConfig.defaultSize!,
                        height: 26.5 * SizeConfig.defaultSize!,
                        margin: EdgeInsets.zero,
                        decoration: ShapeDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 2 * SizeConfig.defaultSize!),
                            Container(
                                width: 50 * SizeConfig.defaultSize!,
                                height: 16 * SizeConfig.defaultSize!,
                                child: Center(
                                  child: Text(
                                    "This dialogue highlights the mermaid's realization\nof the value of her voice, its intangible beauty,\nand its role in her pursuit of true love and self-discovery.\nDespite losing her voice, she finds the strength to communicate\nthrough her heart and believes that love goes beyond words.\nThe journey becomes an opportunity for her to uncover\nher true essence and understand the essence of love and freedom.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 1.8 * SizeConfig.defaultSize!,
                                      fontFamily: 'Molengo',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  // child: SingleChildScrollView(
                                  //   child: RichText(
                                  //     textAlign: TextAlign.center,
                                  //     text: TextSpan(
                                  //       children: [
                                  //         TextSpan(
                                  //           children: [
                                  // TextSpan(
                                  //   text:
                                  //       'This dialogue highlights the mermaid\'s realization of the value\n',
                                  //   style: TextStyle(
                                  //       fontSize:
                                  //           1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  // TextSpan(
                                  //   text:
                                  //       'of her voice, its intangible beauty, and its role in her pursuit of\n',
                                  //   style: TextStyle(
                                  //       fontSize:
                                  //           1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  // TextSpan(
                                  //   text:
                                  //       'true love and self-discovery. Despite losing her voice, she finds \n ',
                                  //   style: TextStyle(
                                  //       fontSize:
                                  //           1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  // TextSpan(
                                  //   text:
                                  //       'the strength to communicate through her heart and believes that \n',
                                  //   style: TextStyle(
                                  //       fontSize:
                                  //           1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  // TextSpan(
                                  //   text:
                                  //       'love goes beyond words. The journey becomes  an opportunity for her\n',
                                  //   style: TextStyle(
                                  //       fontSize:
                                  //           1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  // TextSpan(
                                  //   text:
                                  //       'to uncover her true essence and understand the essence of love and freedom.\n',
                                  //   style: TextStyle(
                                  //       fontSize:
                                  //           1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  // TextSpan(
                                  //   text:
                                  //       'and passions within me will not easily fade away. Love transcends\n',
                                  //   style: TextStyle(
                                  //       fontSize: 1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  // TextSpan(
                                  //   text:
                                  //       'language. In this quest to reclaim my precious voice, I will discover my\n',
                                  //   style: TextStyle(
                                  //       fontSize: 1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  // TextSpan(
                                  //   text:
                                  //       'true self and learn the ways of love and freedom."',
                                  //   style: TextStyle(
                                  //       fontSize: 1.6 * SizeConfig.defaultSize!,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                  //           ],
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                )),
                            Expanded(
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _sendVoiceRemakeClickEvent(
                                              userState.purchase,
                                              userState.record,
                                              userState.voiceId!);
                                          audioPlayer.stop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AudioRecorderRetry(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 31.1 * SizeConfig.defaultSize!,
                                          height: 4.5 * SizeConfig.defaultSize!,
                                          decoration: ShapeDecoration(
                                            color: Color(0xFFFFA91A),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Re-make your voice',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 2.3 *
                                                    SizeConfig.defaultSize!,
                                                fontFamily: 'Molengo',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.3 * SizeConfig.defaultSize!,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.play_arrow,
                                          size: 3 * SizeConfig.defaultSize!,
                                          // color: const Color.fromARGB(
                                          //     255, 194, 120, 209),
                                        ),
                                        onPressed: () {
                                          _sendVoicePlayClickEvent(
                                              userState.purchase,
                                              userState.record,
                                              userState.voiceId!);
                                          inferenceUrl == ""
                                              ? null
                                              : audioPlayer.play(
                                                  UrlSource(inferenceUrl));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ])
                  ],
                ),
              ),
              //   Expanded(
              //     flex: 2,
              //     child: SingleChildScrollView(
              //       child: RichText(
              //         textAlign: TextAlign.center,
              //         text: TextSpan(
              //           children: [
              //             TextSpan(
              //               children: [
              //                 TextSpan(
              //                   text:
              //                       'This dialogue highlights the mermaid\'s realization of the value\n',
              //                   style: TextStyle(
              //                       fontSize: 1.6 * SizeConfig.defaultSize!,
              //                       color: Colors.black,
              //                       fontWeight: FontWeight.bold),
              //                 ),
              //                 TextSpan(
              //                   text:
              //                       'of her voice, its intangible beauty, and its role in her pursuit of\n',
              //                   style: TextStyle(
              //                       fontSize: 1.6 * SizeConfig.defaultSize!,
              //                       color: Colors.black,
              //                       fontWeight: FontWeight.bold),
              //                 ),
              //                 TextSpan(
              //                   text:
              //                       'true love and self-discovery. Despite losing her voice, she finds \n ',
              //                   style: TextStyle(
              //                       fontSize: 1.6 * SizeConfig.defaultSize!,
              //                       color: Colors.black,
              //                       fontWeight: FontWeight.bold),
              //                 ),
              //                 TextSpan(
              //                   text:
              //                       'the strength to communicate through her heart and believes that \n',
              //                   style: TextStyle(
              //                       fontSize: 1.6 * SizeConfig.defaultSize!,
              //                       color: Colors.black,
              //                       fontWeight: FontWeight.bold),
              //                 ),
              //                 TextSpan(
              //                   text:
              //                       'love goes beyond words. The journey becomes  an opportunity for her\n',
              //                   style: TextStyle(
              //                       fontSize: 1.6 * SizeConfig.defaultSize!,
              //                       color: Colors.black,
              //                       fontWeight: FontWeight.bold),
              //                 ),
              //                 TextSpan(
              //                   text:
              //                       'to uncover her true essence and understand the essence of love and freedom.\n',
              //                   style: TextStyle(
              //                       fontSize: 1.6 * SizeConfig.defaultSize!,
              //                       color: Colors.black,
              //                       fontWeight: FontWeight.bold),
              //                 ),
              //                 // TextSpan(
              //                 //   text:
              //                 //       'and passions within me will not easily fade away. Love transcends\n',
              //                 //   style: TextStyle(
              //                 //       fontSize: 16.0,
              //                 //       color: Colors.black,
              //                 //       fontWeight: FontWeight.bold),
              //                 // ),
              //                 // TextSpan(
              //                 //   text:
              //                 //       'language. In this quest to reclaim my precious voice, I will discover my\n',
              //                 //   style: TextStyle(
              //                 //       fontSize: 16.0,
              //                 //       color: Colors.black,
              //                 //       fontWeight: FontWeight.bold),
              //                 // ),
              //                 // TextSpan(
              //                 //   text:
              //                 //       'true self and learn the ways of love and freedom."',
              //                 //   style: TextStyle(
              //                 //       fontSize: 16.0,
              //                 //       color: Colors.black,
              //                 //       fontWeight: FontWeight.bold),
              //                 // ),
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              //   Expanded(
              //     flex: 1,
              //     child: Stack(
              //       alignment: Alignment.centerLeft,
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             TextButton(
              //               onPressed: () {
              //                 audioPlayer.stop();
              //                 Navigator.push(
              //                   context,
              //                   MaterialPageRoute(
              //                     builder: (context) => const AudioRecorderRetry(
              //                         // rerecord: true,
              //                         // mustDelete: widget.path,
              //                         ),
              //                   ),
              //                 );
              //               },
              //               style: TextButton.styleFrom(
              //                 shape: RoundedRectangleBorder(
              //                   borderRadius:
              //                       BorderRadius.circular(8.0), // 원하는 모양의 네모 박스로 변경
              //                 ),
              //                 backgroundColor:
              //                     const Color.fromARGB(255, 194, 120, 209),
              //               ),
              //               child: const Text(
              //                 ' Re-make your voice ',
              //                 style: TextStyle(color: Colors.white),
              //               ),
              //             ),
              //             SizedBox(
              //               width: 3.0 * SizeConfig.defaultSize!,
              //             ),
              //             IconButton(
              //               icon: Icon(
              //                 Icons.play_arrow,
              //                 size: 3 * SizeConfig.defaultSize!,
              //                 color: const Color.fromARGB(255, 194, 120, 209),
              //               ),
              //               onPressed: () {
              //                 audioPlayer.play(UrlSource(widget.infenrencedVoice));
              //               },
              //             ),
              //             // SizedBox(
              //             //   width: 3 * SizeConfig.defaultSize!,
              //             // ),
              //             // TextButton(
              //             //   onPressed: () {
              //             //     audioPlayer.stop();
              //             //     Navigator.push(
              //             //       context,
              //             //       MaterialPageRoute(
              //             //         builder: (context) => const HomeScreen(),
              //             //       ),
              //             //     );
              //             //   },
              //             // style: TextButton.styleFrom(
              //             //   shape: RoundedRectangleBorder(
              //             //     borderRadius:
              //             //         BorderRadius.circular(8.0), // 원하는 모양의 네모 박스로 변경
              //             //   ),
              //             //   backgroundColor:
              //             //       const Color.fromARGB(255, 194, 120, 209),
              //             // ),
              //             // child: const Text(
              //             //   '    I love it!    ',
              //             //   style: TextStyle(color: Colors.white),
              //             // ),
              //             // ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendVoiceRemakeClickEvent(purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_remake_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendVoiceTextClickEvent(purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_text_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendVoiceIconClickEvent(purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_icon_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendVoiceNameClickEvent(purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_name_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendVoicePlayClickEvent(purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_play_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendVoiceViewEvent(purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_view',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
