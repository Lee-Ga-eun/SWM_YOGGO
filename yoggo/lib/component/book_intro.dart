import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/sub.dart';
import 'package:yoggo/component/rec_info.dart';
import 'book_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yoggo/size_config.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'globalCubit/user/user_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookIntro extends StatefulWidget {
  final String title, thumb, summary;
  final int id;

  const BookIntro({
    // super.key,
    Key? key,
    required this.title,
    required this.thumb,
    required this.id,
    required this.summary,
  }) : super(key: key);

  @override
  _BookIntroState createState() => _BookIntroState();
}

class _BookIntroState extends State<BookIntro> {
  bool isSelected = true;
  bool isClicked = false;
  bool isClicked0 = true;
  bool isClicked1 = false;
  bool isClicked2 = false;
  //bool isPurchased = false;
  bool isLoading = false;
  bool wantPurchase = false;
  bool wantRecord = false;
  bool wantInference = false;
  bool completeInference = true;
  //late String voiceIcon = "😃";
  //late String voiceName = "";
  late int inferenceId = 0;
  late String token;
  String text = '';
  int contentVoiceId = 10;
  //String voices='';
  List<dynamic> voices = [];
  int cvi = 0;
  int vi = 0;
  bool canChanged = true;
  int lastPage = 0;
  int contentId = 1;

  Future<void> fetchPageData() async {
    final url = 'https://yoggo-server.fly.dev/content/${widget.id}';
    final response = await http.get(Uri.parse(url));
    if (mounted) {
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        // print(responseData);
        Map<String, dynamic> data = responseData[0];
        voices = data['voice'];
        for (var voice in voices) {
          if (voice['voiceId'] == 1) {
            cvi = voice['contentVoiceId'];
            vi = 1;
          }
        }
        final contentText = data['voice'][0]['voiceName'];
        lastPage = data['last'];
        contentId = data['contentId'];

        setState(() {
          text = contentText;
          contentVoiceId = data['voice'][0]['contentVoiceId'];
        });
      } else {}
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPageData();
    getToken();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Amplitude amplitude = Amplitude.getInstance();
  // static Analytics_config.analytics.logEvent("suhwanc");

  Future<void> _sendBookMyVoiceClickEvent(
      userId, purchase, record, contentId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_my_voice_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'contentId': contentId,
        },
      );
      amplitude.logEvent(
        'book_my_voice_click',
        eventProperties: {
          'userId': userId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'contentId': contentId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookVoiceClickEvent(
      userId, contentVoiceId, contentId, voiceId, purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_voice_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'book_voice_click',
        eventProperties: {
          'userId': userId,
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookStartClickEvent(
      userId, contentVoiceId, contentId, voiceId, purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_start_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'book_start_click',
        eventProperties: {
          'userId': userId,
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookIntroViewEvent(
      userId, contentId, purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_intro_view',
        parameters: <String, dynamic>{
          'userId': userId,
          'contentId': contentId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'book_intro_view',
        eventProperties: {
          'userId': userId,
          'contentId': contentId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookIntroXClickEvent(
      userId, contentId, purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_intro_x_click',
        parameters: <String, dynamic>{
          'userId': userId,
          'contentId': contentId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'book_intro_x_click',
        eventProperties: {
          'userId': userId,
          'contentId': contentId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookLoadingViewEvent(
      userId, contentVoiceId, purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_loading_view',
        parameters: <String, dynamic>{
          'userId': userId,
          'contentId': contentId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'book_loading_view',
        eventProperties: {
          'userId': userId,
          'contentId': contentId,
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      purchaseInfo(token);
      checkInference(token);
    });
  }

//구매한 사람인지, 이 책이 인퍼런스되어 있는지 확인
  Future<String> purchaseInfo(String token) async {
    var url = Uri.parse(
        'https://yoggo-server.fly.dev/user/purchaseInfo/${widget.id}');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        inferenceId = json.decode(response.body)['inference'];
        print(inferenceId);
      });
      return response.body;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

//인퍼런스 안 되어 있다면 시작하도록
  Future<void> startInference(String token) async {
    var url = Uri.parse('https://yoggo-server.fly.dev/producer/book');
    Map data = {'contentId': widget.id};
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          isLoading = true;
          inferenceId = json.decode(response.body)['id'];
          checkInference(token);
        });
      }
    } else {
      throw Exception('Failed to start inference');
    }
  }

//인퍼런스 완료 되었는지 (ContentVoice) 확인
  Future<bool> checkInference(String token) async {
    var url = Uri.parse(
        'https://yoggo-server.fly.dev/content/inference/${widget.id}');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> responseData = jsonDecode(response.body);
      // print(responseData);
      bool data = responseData[0];
      if (data == true) {
        setState(() {
          isLoading = false;
          completeInference = true;
        });
        return true;
      } else {
        setState(() {
          isLoading = true;
          //loadData(token);
          Future.delayed(const Duration(seconds: 1), () {
            checkInference(token);
          });
        });
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // precacheImages(context);
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    _sendBookIntroViewEvent(
        userState.userId, widget.id, userState.purchase, userState.record);
    SizeConfig().init(context);
    if (cvi == 0) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/bkground.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            // 로딩 화면
            child: LoadingAnimationWidget.fourRotatingDots(
              color: const Color.fromARGB(255, 255, 169, 26),
              size: SizeConfig.defaultSize! * 10,
            ),
          ),
        ),
      );
    }
    return Scaffold(
        backgroundColor: const Color(0xFFF1ECC9).withOpacity(1),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/bkground.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                // left: 0.5 * SizeConfig.defaultSize!,
                top: SizeConfig.defaultSize!,
              ),
              child: SafeArea(
                bottom: false,
                top: false,
                minimum: EdgeInsets.only(right: 3 * SizeConfig.defaultSize!),
                child: Column(children: [
                  Expanded(
                      // HEADER
                      flex: 12,
                      child: Row(children: [
                        Expanded(
                            flex: 1,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.all(
                                        0.2 * SizeConfig.defaultSize!),
                                    icon: Icon(Icons.clear,
                                        size: 3 * SizeConfig.defaultSize!),
                                    onPressed: () {
                                      _sendBookIntroXClickEvent(
                                          userState.userId,
                                          widget.id,
                                          userState.purchase,
                                          userState.record);
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ])),
                        Expanded(
                            flex: 8,
                            child:
                                Container(color: Color.fromARGB(0, 0, 0, 0))),
                        Expanded(
                            flex: 1,
                            child: Container(color: Color.fromARGB(0, 0, 0, 0)))
                      ])),
                  Expanded(
                    // BODY
                    flex: 74,
                    child: Row(children: [
                      Expanded(
                        // 썸네일 사진
                        flex: 4,
                        child: Container(
                          color: Color.fromARGB(0, 0, 0, 0),
                          child: Hero(
                            tag: widget.id,
                            child: Center(
                              child: Container(
                                  child: Column(children: [
                                Container(
                                    width: 30 * SizeConfig.defaultSize!,
                                    height: 30 * SizeConfig.defaultSize!,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: CachedNetworkImage(
                                        imageUrl: widget.thumb))
                                // Image.network(widget.thumb))
                              ])),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        // 제목, 성우, 요약
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                  fontSize: 3.2 * SizeConfig.defaultSize!,
                                  fontFamily: 'BreeSerif'),
                            ),
                            SizedBox(
                              height: userState.purchase
                                  ? 1 * SizeConfig.defaultSize!
                                  : 1.5 * SizeConfig.defaultSize!,
                            ),
                            Row(
                              //  mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                userState.purchase
                                    ? userState.record
                                        ? inferenceId == 0
                                            ? GestureDetector(
                                                // purchase & record
                                                // no start Inference
                                                onTap: () {
                                                  _sendBookMyVoiceClickEvent(
                                                    userState.userId,
                                                    userState.purchase,
                                                    userState.record,
                                                    contentId,
                                                  );
                                                  setState(() {
                                                    canChanged = false;
                                                    wantInference = true;
                                                  });
                                                },
                                                child: Column(children: [
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 0 *
                                                              SizeConfig
                                                                  .defaultSize!),
                                                      child: Image.asset(
                                                        'lib/images/icons/${userState.voiceIcon}-uc.png',
                                                        height: SizeConfig
                                                                .defaultSize! *
                                                            7,
                                                      )),
                                                  SizedBox(
                                                      height: SizeConfig
                                                              .defaultSize! *
                                                          0.3),
                                                  Text(userState.voiceName!,
                                                      style: TextStyle(
                                                          fontFamily: 'Gaegu',
                                                          // fontWeight:
                                                          //     FontWeight.w800,
                                                          fontSize: 1.8 *
                                                              SizeConfig
                                                                  .defaultSize!))
                                                ]))
                                            : isLoading
                                                ? GestureDetector(
                                                    // purchase & record
                                                    // no complete inference
                                                    onTap: () {
                                                      _sendBookMyVoiceClickEvent(
                                                        userState.userId,
                                                        userState.purchase,
                                                        userState.record,
                                                        contentId,
                                                      );

                                                      setState(() {
                                                        canChanged = false;
                                                        completeInference =
                                                            false;
                                                      });
                                                    },
                                                    child: Column(children: [
                                                      Stack(children: [
                                                        Image.asset(
                                                          'lib/images/icons/${userState.voiceIcon}-uc.png',
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              7,
                                                        ),
                                                        const Positioned(
                                                          left: 12,
                                                          right: 12,
                                                          bottom: 12,
                                                          top: 12,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Color(
                                                                0xFFFFA91A),
                                                          ),
                                                        )
                                                      ]),
                                                      SizedBox(
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              0.3),
                                                      Text(userState.voiceName!,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Gaegu',
                                                              // fontWeight:
                                                              //     FontWeight.w800,
                                                              fontSize: 1.8 *
                                                                  SizeConfig
                                                                      .defaultSize!))
                                                    ]))
                                                : GestureDetector(
                                                    // purchase & record
                                                    // complete Inference
                                                    onTap: () {
                                                      _sendBookMyVoiceClickEvent(
                                                        userState.userId,
                                                        userState.purchase,
                                                        userState.record,
                                                        contentId,
                                                      );

                                                      setState(() {
                                                        isClicked = true;
                                                        isClicked0 = false;
                                                        isClicked1 = false;
                                                        isClicked2 = false;
                                                        canChanged = true;
                                                        cvi = inferenceId;
                                                        vi = userState.voiceId!;
                                                      });
                                                    },
                                                    child: Column(children: [
                                                      Padding(
                                                          padding: EdgeInsets.only(
                                                              right: 0 *
                                                                  SizeConfig
                                                                      .defaultSize!),
                                                          child: isClicked
                                                              ? Image.asset(
                                                                  'lib/images/icons/${userState.voiceIcon}-c.png',
                                                                  height: SizeConfig
                                                                          .defaultSize! *
                                                                      7,
                                                                )
                                                              : Image.asset(
                                                                  'lib/images/icons/${userState.voiceIcon}-uc.png',
                                                                  height: SizeConfig
                                                                          .defaultSize! *
                                                                      7,
                                                                )),
                                                      SizedBox(
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              0.3),
                                                      Text(userState.voiceName!,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Gaegu',
                                                              // fontWeight:
                                                              //     FontWeight.w800,
                                                              fontSize: 1.8 *
                                                                  SizeConfig
                                                                      .defaultSize!))
                                                    ]))
                                        : GestureDetector(
                                            // no record
                                            onTap: () {
                                              setState(() {
                                                _sendBookMyVoiceClickEvent(
                                                  userState.userId,
                                                  userState.purchase,
                                                  userState.record,
                                                  contentId,
                                                );
                                                wantRecord = true;
                                              });
                                            },
                                            child: Center(
                                              child: Column(
                                                // 결제 안 한 사람
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 0 *
                                                            SizeConfig
                                                                .defaultSize!,
                                                        left: 0 *
                                                            SizeConfig
                                                                .defaultSize!),
                                                    child: Image.asset(
                                                        'lib/images/lock.png',
                                                        height: SizeConfig
                                                                .defaultSize! *
                                                            6.5,
                                                        colorBlendMode:
                                                            BlendMode.srcATop,
                                                        color: isClicked
                                                            ? null
                                                            : const Color
                                                                    .fromARGB(
                                                                200,
                                                                255,
                                                                255,
                                                                255)),
                                                  ),
                                                  SizedBox(
                                                      height: SizeConfig
                                                              .defaultSize! *
                                                          0.3),
                                                  Text('Mine',
                                                      style: TextStyle(
                                                          fontFamily: 'Gaegu',
                                                          fontSize: 1.8 *
                                                              SizeConfig
                                                                  .defaultSize!))
                                                ],
                                              ),
                                            ))
                                    : GestureDetector(
                                        //no Purchase
                                        onTap: () {
                                          setState(() {
                                            wantPurchase = true;
                                          });
                                        },
                                        child: Center(
                                          child: Column(
                                            // 결제 안 한 사람
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: 0 *
                                                        SizeConfig.defaultSize!,
                                                    left: 0 *
                                                        SizeConfig
                                                            .defaultSize!),
                                                child: Image.asset(
                                                    'lib/images/lock.png',
                                                    height: SizeConfig
                                                            .defaultSize! *
                                                        6.5,
                                                    colorBlendMode:
                                                        BlendMode.srcATop,
                                                    color: isClicked
                                                        ? null
                                                        : const Color.fromARGB(
                                                            200,
                                                            255,
                                                            255,
                                                            255)),
                                              ),
                                              SizedBox(
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          0.3),
                                              Text('Mine',
                                                  style: TextStyle(
                                                      fontFamily: 'Gaegu',
                                                      fontSize: 1.8 *
                                                          SizeConfig
                                                              .defaultSize!))
                                            ],
                                          ),
                                        )),
                                SizedBox(
                                  // color: ,
                                  width: 1.5 * SizeConfig.defaultSize!,
                                ),
                                // Jolly
                                GestureDetector(
                                    onTap: () {
                                      cvi = voices[0]['contentVoiceId'];
                                      vi = voices[0]['voiceId'];
                                      _sendBookVoiceClickEvent(
                                          userState.userId,
                                          cvi,
                                          contentId,
                                          vi,
                                          userState.purchase,
                                          userState
                                              .record); // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                      setState(() {
                                        isClicked0 = true;
                                        isClicked = !isClicked0;
                                        isClicked1 = !isClicked0;
                                        isClicked2 = !isClicked0;
                                        canChanged = true; // 클릭 상태
                                      });
                                    },
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  right: 0 *
                                                      SizeConfig.defaultSize!),
                                              child: Image.asset(
                                                  'lib/images/jolly.png',
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          6.5,
                                                  colorBlendMode:
                                                      BlendMode.srcATop,
                                                  color: isClicked0
                                                      ? null
                                                      : const Color.fromARGB(
                                                          150, 255, 255, 255))
                                              /*child: isClicked0
                                            ? Container(
                                                height: SizeConfig
                                                        .defaultSize! *
                                                    6.6,
                                                decoration:
                                                    BoxDecoration(
                                                  shape:
                                                      BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color
                                                            .fromARGB(
                                                        255,
                                                        255,
                                                        255,
                                                        255),
                                                    width: 3.5,
                                                  ),
                                                ),
                                                child: Image.asset(
                                                  'lib/images/jolly.png',
                                                  height: SizeConfig
                                                          .defaultSize! *
                                                      6.5,
                                                ),
                                              )
                                            : Image.asset(
                                                'lib/images/jolly.png',
                                                height: SizeConfig
                                                        .defaultSize! *
                                                    6.5,
                                              )*/
                                              ),
                                          SizedBox(
                                              height: SizeConfig.defaultSize! *
                                                  0.3),
                                          Text(voices[0]['voiceName'],
                                              style: TextStyle(
                                                  fontFamily: 'Gaegu',
                                                  fontSize: 1.8 *
                                                      SizeConfig.defaultSize!))
                                        ],
                                      ),
                                    )),
                                SizedBox(
                                  width: 1.5 * SizeConfig.defaultSize!,
                                ),
                                // Morgan
                                GestureDetector(
                                    onTap: () {
                                      cvi = voices[1]['contentVoiceId'];
                                      vi = voices[1]['voiceId'];

                                      _sendBookVoiceClickEvent(
                                          userState.userId,
                                          cvi,
                                          contentId,
                                          vi,
                                          userState.purchase,
                                          userState
                                              .record); // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                      setState(() {
                                        isClicked1 = true;
                                        isClicked = !isClicked1;
                                        isClicked0 = !isClicked1;
                                        isClicked2 = !isClicked1;
                                        canChanged = true; // 클릭 상태
                                      });
                                    },
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 0 *
                                                    SizeConfig.defaultSize!),
                                            child: Image.asset(
                                                'lib/images/morgan.png',
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        6.5,
                                                colorBlendMode:
                                                    BlendMode.srcATop,
                                                color: isClicked1
                                                    ? null
                                                    : const Color.fromARGB(
                                                        150, 255, 255, 255)),
                                            /*child: isClicked1
                                            ? Container(
                                                height: SizeConfig
                                                        .defaultSize! *
                                                    6.6,
                                                decoration:
                                                    BoxDecoration(
                                                  shape:
                                                      BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color
                                                            .fromARGB(
                                                        255,
                                                        255,
                                                        255,
                                                        255),
                                                    width: 3.5,
                                                  ),
                                                ),
                                                child: Image.asset(
                                                  'lib/images/morgan.png',
                                                  height: SizeConfig
                                                          .defaultSize! *
                                                      6.5,
                                                ),
                                              )
                                            : Image.asset(
                                                'lib/images/morgan.png',
                                                height: SizeConfig
                                                        .defaultSize! *
                                                    6.5,
                                              )),*/
                                          ),
                                          SizedBox(
                                              height: SizeConfig.defaultSize! *
                                                  0.3),
                                          Text(voices[1]['voiceName'],
                                              style: TextStyle(
                                                  fontFamily: 'Gaegu',
                                                  fontSize: 1.8 *
                                                      SizeConfig.defaultSize!))
                                        ],
                                      ),
                                    )),
                                SizedBox(
                                  width: 1.5 * SizeConfig.defaultSize!,
                                ),
                                // Eric
                                GestureDetector(
                                    onTap: () {
                                      cvi = voices[2]['contentVoiceId'];
                                      vi = voices[2]['voiceId'];
                                      // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                      _sendBookVoiceClickEvent(
                                          userState.userId,
                                          cvi,
                                          contentId,
                                          vi,
                                          userState.purchase,
                                          userState.record);
                                      setState(() {
                                        isClicked2 = true;
                                        isClicked = !isClicked2;
                                        isClicked0 = !isClicked2;
                                        isClicked1 = !isClicked2;
                                        canChanged = true; // 클릭 상태
                                      });
                                    },
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 0 *
                                                    SizeConfig.defaultSize!),
                                            child: Image.asset(
                                                'lib/images/eric.png',
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        6.5,
                                                colorBlendMode:
                                                    BlendMode.srcATop,
                                                color: isClicked2
                                                    ? null
                                                    : const Color.fromARGB(
                                                        150, 255, 255, 255)),
                                            /*child: isClicked2
                                            ? Container(
                                                height: SizeConfig
                                                        .defaultSize! *
                                                    6.6,
                                                decoration:
                                                    BoxDecoration(
                                                  shape:
                                                      BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color
                                                            .fromARGB(
                                                        255,
                                                        255,
                                                        255,
                                                        255),
                                                    width: 3.5,
                                                  ),
                                                ),
                                                child: Image.asset(
                                                  'lib/images/eric.png',
                                                  height: SizeConfig
                                                          .defaultSize! *
                                                      6.5,
                                                ),
                                              )
                                            : Image.asset(
                                                'lib/images/eric.png',
                                                height: SizeConfig
                                                        .defaultSize! *
                                                    6.5,
                                              )*/
                                          ),
                                          SizedBox(
                                              height: SizeConfig.defaultSize! *
                                                  0.3),
                                          Text(voices[2]['voiceName'],
                                              style: TextStyle(
                                                  fontFamily: 'Gaegu',
                                                  fontSize: 1.8 *
                                                      SizeConfig.defaultSize!)),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                            SizedBox(
                                height:
                                    SizeConfig.defaultSize! //userState.purchase
                                //? 4
                                //: 4 * SizeConfig.defaultSize!,
                                ),
                            Expanded(
                                flex: 2,
                                child: ListView(children: [
                                  Padding(
                                    // Summary
                                    padding: EdgeInsets.only(
                                      right: 0 * SizeConfig.defaultSize!,
                                      top: 0 * SizeConfig.defaultSize!,
                                    ),
                                    child: Text(
                                      widget.summary,
                                      style: TextStyle(
                                          fontFamily: 'Gaegu',
                                          fontWeight: FontWeight.w400,
                                          fontSize:
                                              SizeConfig.defaultSize! * 2.3),
                                    ),
                                  ),
                                ]))
                          ],
                        ),
                      ),
                    ]),
                  ),

                  Expanded(
                    // FOOTER
                    flex: 12,
                    child: Row(children: [
                      Expanded(
                        flex: 1,
                        child: Container(color: Color.fromARGB(0, 0, 100, 0)),
                      ),
                      Expanded(
                          flex: 8,
                          child: Container(color: Color.fromARGB(0, 0, 0, 0))),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                            onTap: () async {
                              print('인퍼런스아이디');
                              print(inferenceId);
                              (cvi == inferenceId) // 원래는 cvi==inferenceId
                                  ? await checkInference(token)
                                      ? {
                                          _sendBookStartClickEvent(
                                              userState.userId,
                                              cvi,
                                              contentId,
                                              vi,
                                              userState.purchase,
                                              userState.record),
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BookPage(
                                                  // 다음 화면으로 contetnVoiceId를 가지고 이동
                                                  contentVoiceId: cvi,
                                                  voiceId: vi,
                                                  contentId: contentId,
                                                  lastPage: lastPage,
                                                  isSelected: true,
                                                ),
                                              ))
                                        }
                                      : setState(() {
                                          completeInference = false;
                                        })
                                  : canChanged
                                      ? {
                                          _sendBookStartClickEvent(
                                              userState.userId,
                                              cvi,
                                              contentId,
                                              vi,
                                              userState.purchase,
                                              userState.record),
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BookPage(
                                                // 다음 화면으로 contetnVoiceId를 가지고 이동
                                                contentVoiceId: cvi,
                                                voiceId: vi,
                                                contentId: contentId,
                                                lastPage: lastPage,
                                                isSelected: true,
                                              ),
                                            ),
                                          )
                                        }
                                      : null;
                            },
                            // next 화살표 시작

                            child: Container(
                              // [->]
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.end, // 아이콘을 맨 왼쪽으로 정렬
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                        0.2 * SizeConfig.defaultSize!),
                                    child: Icon(
                                      // padding: EdgeInsets.all(
                                      //     0.2 * SizeConfig.defaultSize!),
                                      Icons.arrow_forward,
                                      size: 3 * SizeConfig.defaultSize!,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            )),
                        // next 화살표 끝
                      )
                    ]),
                  ), // --------------------성우 아이콘 배치 완료  ---------
                ]),
              ),
            ),
          ),
          Visibility(
            visible: wantPurchase,
            child: AlertDialog(
              title: const Text('Register your voice!'),
              content: const Text('Click OK to go to voice registration.'),
              actions: [
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        wantPurchase = false;
                      });
                    });
                  },
                  child: const Text('later'),
                ),
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Purchase()),
                      );
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          Visibility(
            visible: wantRecord,
            child: AlertDialog(
              title: const Text('Register your voice!'),
              content: const Text(
                  'After registering your voice, listen to the book with your voice.'),
              actions: [
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        wantRecord = false;
                      });
                    });
                  },
                  child: const Text('later'),
                ),
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RecInfo()),
                      );
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          Visibility(
            visible: !completeInference,
            child: AlertDialog(
              title: const Text('Please wait a minute.'),
              content: const Text(
                  "We're making a book with your voice. \nIf you want to read the book right now, please choose a different voice actor!"),
              actions: [
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    setState(() {
                      completeInference = true;
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          Visibility(
            visible: wantInference,
            child: AlertDialog(
              title: const Text('Read this book with your voice'),
              content: const Text(
                "You can make this book with your voice. \nDo you want to make it?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    setState(() {
                      wantInference = false;
                    });
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    startInference(token);
                    setState(() {
                      wantInference = false;
                    });
                  },
                  child: const Text('YES'),
                ),
              ],
            ),
          ),
        ]));
  }
}
