import 'package:amplitude_flutter/amplitude.dart';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/size_config.dart';
import 'globalCubit/user/user_cubit.dart';
import 'home/view/home.dart';
import 'rec_re.dart';
import 'package:audioplayers/audioplayers.dart';

class VoiceProfile extends StatefulWidget {
  // final String infenrencedVoice;

  const VoiceProfile({
    super.key,
    // required this.infenrencedVoice,
  });

  @override
  _VoiceProfileState createState() => _VoiceProfileState();
}

class _VoiceProfileState extends State<VoiceProfile> {
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
  static Amplitude amplitude = Amplitude.getInstance(instanceName: "SayIT");

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    _sendVoiceViewEvent(userState.userId, userState.purchase, userState.record,
        userState.voiceId!);
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
          minimum: EdgeInsets.only(left: 7 * SizeConfig.defaultSize!),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        // color: Color.fromARGB(200, 202, 20, 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(Icons.clear,
                                    size: 3 * SizeConfig.defaultSize!),
                                onPressed: () {
                                  audioPlayer.stop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                },
                              )
                            ]),
                      )),
                  Expanded(
                      flex: 8,
                      child: Container(
                        // color: Color.fromARGB(232, 0, 26, 64),
                        child: Row(
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
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(color: Color.fromARGB(0, 0, 0, 0)))
                ]),
              ),
              Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 1.5 * SizeConfig.defaultSize!,
                      ),
                      Row(
                        children: [
                          // SizedBox(
                          //   width: SizeConfig.defaultSize!,
                          // ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _sendVoiceIconClickEvent(
                                      userState.userId,
                                      userState.purchase,
                                      userState.record,
                                      userState.voiceId);
                                },
                                child: Container(
                                  width: 18 * SizeConfig.defaultSize!,
                                  height: 19 * SizeConfig.defaultSize!,
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
                                      height: SizeConfig.defaultSize! * 2.8,
                                    ),
                                    Image.asset(
                                      'lib/images/icons/${userState.voiceIcon}-c.png',
                                      height: SizeConfig.defaultSize! * 13.5,
                                    ),
                                  ]),
                                ),
                              ),
                              SizedBox(
                                height: 1.6 * SizeConfig.defaultSize!,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _sendVoiceNameClickEvent(
                                      userState.userId,
                                      userState.purchase,
                                      userState.record,
                                      userState.voiceId);
                                },
                                child: Container(
                                  width: 18 * SizeConfig.defaultSize!,
                                  height: 9 * SizeConfig.defaultSize!,
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
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            width: SizeConfig.defaultSize! * 2,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 55 * SizeConfig.defaultSize!,
                                  height: 29.6 * SizeConfig.defaultSize!,
                                  margin: EdgeInsets.zero,
                                  decoration: ShapeDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: inferenceUrl == ""
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                              const CircularProgressIndicator(
                                                  color: Color(0xFFFFA91A)),
                                              SizedBox(
                                                height: SizeConfig.defaultSize!,
                                              ),
                                              Text(
                                                "We are making your voice!",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 3 *
                                                      SizeConfig.defaultSize!,
                                                  fontFamily: 'Molengo',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ])
                                      : Column(
                                          children: [
                                            SizedBox(
                                                height: 3.2 *
                                                    SizeConfig.defaultSize!),
                                            GestureDetector(
                                              onTap: () {
                                                _sendVoiceScriptClickEvent(
                                                    userState.userId,
                                                    userState.purchase,
                                                    userState.record,
                                                    userState.voiceId);
                                              },
                                              child: Container(
                                                width: 50 *
                                                    SizeConfig.defaultSize!,
                                                height: 16 *
                                                    SizeConfig.defaultSize!,
                                                child: Center(
                                                  child: Text(
                                                    "This dialogue highlights the mermaid's realization\nof the value of her voice, its intangible beauty,\nand its role in her pursuit of true love and self-discovery.\nDespite losing her voice, she finds the strength to communicate\nthrough her heart and believes that love goes beyond words.\nThe journey becomes an opportunity for her to uncover\nher true essence and understand the essence of love and freedom.",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 1.8 *
                                                          SizeConfig
                                                              .defaultSize!,
                                                      fontFamily: 'Molengo',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Stack(
                                                alignment: Alignment.centerLeft,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          _sendVoiceRerecClickEvent(
                                                              userState.userId,
                                                              userState
                                                                  .purchase,
                                                              userState.record,
                                                              userState
                                                                  .voiceId);
                                                          audioPlayer.stop();
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const RecRe(),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 31.1 *
                                                              SizeConfig
                                                                  .defaultSize!,
                                                          height: 4.5 *
                                                              SizeConfig
                                                                  .defaultSize!,
                                                          decoration:
                                                              ShapeDecoration(
                                                            color: Color(
                                                                0xFFFFA91A),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'Re-make your voice',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 2.3 *
                                                                    SizeConfig
                                                                        .defaultSize!,
                                                                fontFamily:
                                                                    'Molengo',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5.3 *
                                                            SizeConfig
                                                                .defaultSize!,
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.play_arrow,
                                                          size: 3 *
                                                              SizeConfig
                                                                  .defaultSize!,
                                                          // color: const Color.fromARGB(
                                                          //     255, 194, 120, 209),
                                                        ),
                                                        onPressed: () {
                                                          _sendVoicePlayClickEvent(
                                                              userState.userId,
                                                              userState
                                                                  .purchase,
                                                              userState.record,
                                                              userState
                                                                  .voiceId!);
                                                          audioPlayer.play(
                                                              UrlSource(
                                                                  inferenceUrl));
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
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendVoiceRerecClickEvent(
      userId, purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_rerec_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
      await amplitude.logEvent(
        'voice_rerec_click',
        eventProperties: {
          'userId': userId,
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

  Future<void> _sendVoiceScriptClickEvent(
      userId, purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_script_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
      await amplitude.logEvent(
        'voice_script_click',
        eventProperties: {
          'userId': userId,
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

  Future<void> _sendVoiceIconClickEvent(
      userId, purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_icon_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
      await amplitude.logEvent(
        'voice_icon_click',
        eventProperties: {
          'userId': userId,
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

  Future<void> _sendVoiceNameClickEvent(
      userId, purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_name_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
      await amplitude.logEvent(
        'voice_name_click',
        eventProperties: {
          'userId': userId,
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

  Future<void> _sendVoicePlayClickEvent(
      userId, purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_play_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
      await amplitude.logEvent(
        'voice_play_click',
        eventProperties: {
          'userId': userId,
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

  Future<void> _sendVoiceViewEvent(userId, purchase, record, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'voice_view',
        parameters: <String, dynamic>{
          'userId': userId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'voiceId': voiceId,
        },
      );
      await amplitude.logEvent(
        'voice_view',
        eventProperties: {
          'userId': userId,
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
