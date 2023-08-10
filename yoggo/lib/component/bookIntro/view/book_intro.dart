import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/sub.dart';
import 'package:yoggo/component/rec_info.dart';
import '../../book_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yoggo/size_config.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../globalCubit/user/user_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../viewModel/book_intro_model.dart';
import '../viewModel/book_intro_cubit.dart';

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
  //static bool isClicked = false;
  //static bool isClicked0 = true;
  ValueNotifier<bool> isClicked = ValueNotifier<bool>(false);
  ValueNotifier<bool> isClicked0 = ValueNotifier<bool>(true);
  ValueNotifier<bool> isClicked1 = ValueNotifier<bool>(false);
  ValueNotifier<bool> isClicked2 = ValueNotifier<bool>(false);
  ValueNotifier<bool> canChanged = ValueNotifier<bool>(true);
  ValueNotifier<bool> wantInference = ValueNotifier<bool>(false);
  ValueNotifier<bool> wantRecord = ValueNotifier<bool>(false);

  //static bool isClicked1 = false;
  //static bool isClicked2 = false;
  bool isPurchased = false;
  bool isLoading = false;
  bool wantPurchase = false;
  // bool wantRecord = false;
  //bool wantInference = false;
  bool completeInference = true;
  //late String voiceIcon = "😃";
  //late String voiceName = "";
  static int inferenceId = 0;
  late String token;
  String text = '';
  //int contentVoiceId = 10;
  //String voices='';
  // List<dynamic> voices = [];
  //int cvi = 21; // 여기를 성우의 디폴트 값을 넣어줘야 함
  int vi = 0;
  //bool canChanged = true;
  // int lastPage = 0;
  int contentId = 1;

  @override
  void dispose() {
    isClicked.dispose();
    isClicked0.dispose();
    isClicked1.dispose();
    isClicked2.dispose();
    wantInference.dispose();
    wantRecord.dispose();
    canChanged.dispose();
    super.dispose();
  }

  Future<void> fetchPageData() async {
    final url = 'https://yoggo-server.fly.dev/content/${widget.id}';
    final response = await http.get(Uri.parse(url));
    if (mounted) {
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        // print(responseData);
        Map<String, dynamic> data = responseData[0];
        // voices = data['voice'];
        // for (var voice in voices) {
        //   if (voice['voiceId'] == 1) {
        //     cvi = voice['contentVoiceId'];
        //     vi = 1;
        //   }
        // }
        final contentText = data['voice'][0]['voiceName'];
        //  lastPage = data['last'];
        //  contentId = data['contentId'];

        setState(() {
          text = contentText;
          // contentVoiceId = data['voice'][0]['contentVoiceId'];
        });
      } else {}
    }
  }

  @override
  void initState() {
    super.initState();
    //  cvi = 0;
    contentId = widget.id; // contentId는 init에서
    // fetchPageData();
    getToken();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Amplitude amplitude = Amplitude.getInstance();
  // static Analytics_config.analytics.logEvent("suhwanc");

  Future<void> _sendBookMyVoiceClickEvent(contentId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_my_voice_click',
        parameters: <String, dynamic>{
          'contentId': contentId,
        },
      );
      amplitude.logEvent(
        'book_my_voice_click',
        eventProperties: {
          'contentId': contentId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookVoiceClickEvent(
      contentVoiceId, contentId, voiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_voice_click',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
        },
      );
      await amplitude.logEvent(
        'book_voice_click',
        eventProperties: {
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookStartClickEvent(
    contentVoiceId,
    contentId,
    voiceId,
  ) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_start_click',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
        },
      );
      await amplitude.logEvent(
        'book_start_click',
        eventProperties: {
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookIntroViewEvent(
    contentId,
  ) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_intro_view',
        parameters: <String, dynamic>{
          'contentId': contentId,
        },
      );
      await amplitude.logEvent(
        'book_intro_view',
        eventProperties: {
          'contentId': contentId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookIntroXClickEvent(
    contentId,
  ) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_intro_x_click',
        parameters: <String, dynamic>{
          'contentId': contentId,
        },
      );
      await amplitude.logEvent(
        'book_intro_x_click',
        eventProperties: {
          'contentId': contentId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookLoadingViewEvent(
    contentVoiceId,
  ) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_loading_view',
        parameters: <String, dynamic>{
          'contentId': contentId,
        },
      );
      await amplitude.logEvent(
        'book_loading_view',
        eventProperties: {
          'contentId': contentId,
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
        canChanged.value = true;
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
    final bookIntroCubit = context.read<BookIntroCubit>();
    bookIntroCubit.loadBookIntroData(widget.id);
    return BlocBuilder<BookIntroCubit, List<BookIntroModel>>(
        builder: (context, bookIntro) {
      final userCubit = context.watch<UserCubit>();
      final userState = userCubit.state;
      _sendBookIntroViewEvent(widget.id);
      SizeConfig().init(context);
      if (bookIntro.isEmpty) {
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
      } else {
        final String title = bookIntro.first.title;
        List<dynamic> voices = [];
        voices = bookIntro.first.voice;
        int cvi = voices[0]['contentVoiceId'];
        final int lastPage = bookIntro.first.last;
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
                    minimum:
                        EdgeInsets.only(right: 3 * SizeConfig.defaultSize!),
                    child: Column(children: [
                      Expanded(
                          // HEADER
                          flex: 12,
                          child: Row(children: [
                            Expanded(
                                flex: 1,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.all(
                                            0.2 * SizeConfig.defaultSize!),
                                        icon: Icon(Icons.clear,
                                            size: 3 * SizeConfig.defaultSize!),
                                        onPressed: () {
                                          _sendBookIntroXClickEvent(
                                            widget.id,
                                          );
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ])),
                            Expanded(
                                flex: 8,
                                child: Container(
                                    color: const Color.fromARGB(0, 0, 0, 0))),
                            Expanded(
                                flex: 1,
                                child: Container(
                                    color: const Color.fromARGB(0, 0, 0, 0)))
                          ])),
                      Expanded(
                        // BODY
                        flex: 74,
                        child: Row(children: [
                          Expanded(
                            // 썸네일 사진
                            flex: 3,
                            child: Container(
                                color: const Color.fromARGB(0, 0, 0, 0),
                                child: Hero(
                                  tag: widget.id,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                        begin: 30 * SizeConfig.defaultSize!,
                                        end: 30 * SizeConfig.defaultSize!),
                                    duration: const Duration(milliseconds: 300),
                                    builder: (context, value, child) {
                                      return Container(
                                        //  width: 20,
                                        //height: 20,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: child,
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: widget.thumb,
                                      fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조절
                                    ),
                                  ),
                                )),
                          ),
                          SizedBox(
                            width: SizeConfig.defaultSize! * 2,
                          ),
                          Expanded(
                            // 제목, 성우, 요약
                            flex: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
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
                                                        contentId,
                                                      );
                                                      //    setState(() {
                                                      canChanged.value = false;
                                                      wantInference.value =
                                                          true;
                                                      //   });
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
                                                              fontFamily:
                                                                  'Gaegu',
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
                                                            contentId,
                                                          );

                                                          setState(() {
                                                            canChanged.value =
                                                                false;
                                                            completeInference =
                                                                false;
                                                          });
                                                        },
                                                        child: Column(
                                                            children: [
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
                                                              Text(
                                                                  userState
                                                                      .voiceName!,
                                                                  style: TextStyle(
                                                                      fontFamily: 'Gaegu',
                                                                      // fontWeight:
                                                                      //     FontWeight.w800,
                                                                      fontSize: 1.8 * SizeConfig.defaultSize!))
                                                            ]))
                                                    : GestureDetector(
                                                        // purchase & record
                                                        // complete Inference : 책 인퍼런스 완료된 상태
                                                        onTap: () {
                                                          _sendBookMyVoiceClickEvent(
                                                            contentId,
                                                          );
                                                          // setState(() {
                                                          isClicked.value =
                                                              !isClicked.value;
                                                          isClicked0.value =
                                                              false;
                                                          isClicked1.value =
                                                              false;
                                                          isClicked2.value =
                                                              false;
                                                          canChanged.value =
                                                              true;
                                                          cvi = inferenceId;
                                                          vi = userState
                                                              .voiceId!;
                                                          canChanged.value =
                                                              true; // 인퍼런스가 완료됐을 때 바로 화살표가 넘어갈 수 있도록
                                                          //   });
                                                        },
                                                        child:
                                                            ValueListenableBuilder<
                                                                    bool>(
                                                                valueListenable:
                                                                    isClicked,
                                                                builder:
                                                                    (context,
                                                                        value,
                                                                        child) {
                                                                  return Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.only(right: 0 * SizeConfig.defaultSize!),
                                                                          child: isClicked.value
                                                                              ? Image.asset(
                                                                                  'lib/images/icons/${userState.voiceIcon}-c.png',
                                                                                  height: SizeConfig.defaultSize! * 7,
                                                                                )
                                                                              : Image.asset(
                                                                                  'lib/images/icons/${userState.voiceIcon}-uc.png',
                                                                                  height: SizeConfig.defaultSize! * 7,
                                                                                ),
                                                                        ),
                                                                        SizedBox(
                                                                            height:
                                                                                SizeConfig.defaultSize! * 0.3),
                                                                        Text(
                                                                            userState.voiceName!,
                                                                            style: TextStyle(
                                                                                fontFamily: 'Gaegu',
                                                                                // fontWeight:
                                                                                //     FontWeight.w800,
                                                                                fontSize: 1.8 * SizeConfig.defaultSize!))
                                                                      ]);
                                                                }))
                                            : GestureDetector(
                                                // no record
                                                onTap: () {
                                                    _sendBookMyVoiceClickEvent(
                                                      contentId,
                                                    );
                                                  setState(() {
                                                    // wantRecord = true;
                                                  });
                                                  wantRecord.value = true;
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
                                                                BlendMode
                                                                    .srcATop,
                                                            color: isClicked
                                                                    .value
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
                                                              fontFamily:
                                                                  'Gaegu',
                                                              fontSize: 1.8 *
                                                                  SizeConfig
                                                                      .defaultSize!))
                                                    ],
                                                  ),
                                                ))
                                        : GestureDetector(
                                            //no Purchase
                                          _sendBookMyVoiceClickEvent(
                                                            contentId,
                                                          );
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
                                                        color: isClicked.value
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
                                            )),
                                    SizedBox(
                                      // color: ,
                                      width: 1.5 * SizeConfig.defaultSize!,
                                    ),
                                    // Jolly
                                    // GestureDetector(
                                    //     onTap: () {
                                    //       cvi = voices[0]['contentVoiceId'];
                                    //       vi = voices[0]['voiceId'];
                                    //       _sendBookVoiceClickEvent(
                                    //           cvi,
                                    //           contentId,
                                    //           vi); // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                    //       //   setState(() {
                                    //       isClicked0 = true;
                                    //       isClicked = !isClicked0;
                                    //       isClicked1 = !isClicked0;
                                    //       isClicked2 = !isClicked0;
                                    //       canChanged = true; // 클릭 상태
                                    //       //  });
                                    //     },
                                    //     child: Center(
                                    //       child: Column(
                                    //         children: [
                                    //           Padding(
                                    //               padding: EdgeInsets.only(
                                    //                   right: 0 *
                                    //                       SizeConfig
                                    //                           .defaultSize!),
                                    //               child: Image.asset(
                                    //                   'lib/images/jolly.png',
                                    //                   height: SizeConfig
                                    //                           .defaultSize! *
                                    //                       6.5,
                                    //                   colorBlendMode:
                                    //                       BlendMode.srcATop,
                                    //                   color: isClicked0
                                    //                       ? null
                                    //                       : const Color
                                    //                               .fromARGB(150,
                                    //                           255, 255, 255))),
                                    //           SizedBox(
                                    //               height:
                                    //                   SizeConfig.defaultSize! *
                                    //                       0.3),
                                    //           Text(voices[0]['voiceName'],
                                    //               style: TextStyle(
                                    //                   fontFamily: 'Gaegu',
                                    //                   fontSize: 1.8 *
                                    //                       SizeConfig
                                    //                           .defaultSize!))
                                    //         ],
                                    //       ),
                                    //     )),
                                    GestureDetector(
                                      //Jolly
                                      onTap: () {
                                        cvi = voices[0]['contentVoiceId'];
                                        vi = voices[0]['voiceId'];
                                        _sendBookVoiceClickEvent(
                                            cvi, contentId, vi);
                                        isClicked.value = false;
                                        isClicked0.value = true;
                                        isClicked1.value = false;
                                        isClicked2.value = false;
                                        canChanged.value = true; // 클릭 상태
                                      },
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: isClicked0,
                                        builder: (context, value, child) {
                                          return Center(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 0 *
                                                        SizeConfig.defaultSize!,
                                                  ),
                                                  child: Image.asset(
                                                    'lib/images/jolly.png',
                                                    height: SizeConfig
                                                            .defaultSize! *
                                                        6.5,
                                                    colorBlendMode:
                                                        BlendMode.srcATop,
                                                    color: value
                                                        ? null
                                                        : const Color.fromARGB(
                                                            150, 255, 255, 255),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          0.3,
                                                ),
                                                Text(
                                                  voices[0]['voiceName'],
                                                  style: TextStyle(
                                                    fontFamily: 'Gaegu',
                                                    fontSize: 1.8 *
                                                        SizeConfig.defaultSize!,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 1.5 * SizeConfig.defaultSize!,
                                    ),
                                    // Morgan
                                    GestureDetector(
                                      onTap: () {
                                        cvi = voices[1]['contentVoiceId'];
                                        vi = voices[1]['voiceId'];
                                        _sendBookVoiceClickEvent(
                                            cvi, contentId, vi);
                                        isClicked.value = false;
                                        isClicked0.value = false;
                                        isClicked1.value = true;
                                        isClicked2.value = false;
                                        canChanged.value = true; // 클릭 상태
                                      },
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: isClicked1,
                                        builder: (context, value, child) {
                                          return Center(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 0 *
                                                        SizeConfig.defaultSize!,
                                                  ),
                                                  child: Image.asset(
                                                    'lib/images/morgan.png',
                                                    height: SizeConfig
                                                            .defaultSize! *
                                                        6.5,
                                                    colorBlendMode:
                                                        BlendMode.srcATop,
                                                    color: value
                                                        ? null
                                                        : const Color.fromARGB(
                                                            150, 255, 255, 255),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          0.3,
                                                ),
                                                Text(
                                                  voices[1]['voiceName'],
                                                  style: TextStyle(
                                                    fontFamily: 'Gaegu',
                                                    fontSize: 1.8 *
                                                        SizeConfig.defaultSize!,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 1.5 * SizeConfig.defaultSize!,
                                    ),
                                    // Eric
                                    GestureDetector(
                                      onTap: () {
                                        cvi = voices[2]['contentVoiceId'];
                                        vi = voices[2]['voiceId'];
                                        _sendBookVoiceClickEvent(
                                            cvi, contentId, vi);
                                        isClicked.value = false;
                                        isClicked0.value = false;
                                        isClicked1.value = false;
                                        isClicked2.value = true;
                                        canChanged.value = true; // 클릭 상태
                                      },
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: isClicked2,
                                        builder: (context, value, child) {
                                          return Center(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    right: 0 *
                                                        SizeConfig.defaultSize!,
                                                  ),
                                                  child: Image.asset(
                                                    'lib/images/eric.png',
                                                    height: SizeConfig
                                                            .defaultSize! *
                                                        6.5,
                                                    colorBlendMode:
                                                        BlendMode.srcATop,
                                                    color: value
                                                        ? null
                                                        : const Color.fromARGB(
                                                            150, 255, 255, 255),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          0.3,
                                                ),
                                                Text(
                                                  voices[2]['voiceName'],
                                                  style: TextStyle(
                                                    fontFamily: 'Gaegu',
                                                    fontSize: 1.8 *
                                                        SizeConfig.defaultSize!,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: SizeConfig
                                        .defaultSize! //userState.purchase
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
                                                  SizeConfig.defaultSize! *
                                                      2.3),
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
                            child: Container(
                                color: const Color.fromARGB(0, 0, 100, 0)),
                          ),
                          Expanded(
                              flex: 8,
                              child: Container(
                                  color: const Color.fromARGB(0, 0, 0, 0))),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                                onTap: () async {
                                  (cvi == inferenceId) // 원래는 cvi==inferenceId
                                      ? await checkInference(token)
                                          ? {
                                              _sendBookStartClickEvent(
                                                cvi,
                                                contentId,
                                                vi,
                                              ),
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookPage(
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
                                      : canChanged.value
                                          ? {
                                              _sendBookStartClickEvent(
                                                cvi,
                                                contentId,
                                                vi,
                                              ),
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BookPage(
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
                  content: const Text('Click OK to go to register your voice.'),
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
              ValueListenableBuilder<bool>(
                valueListenable: wantRecord,
                builder: (context, value, child) {
                  return Visibility(
                    visible: value,
                    child: AlertDialog(
                      title: const Text('Register your voice!'),
                      content: const Text(
                          'After registering your voice, listen to the book with your voice.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Future.delayed(const Duration(seconds: 1), () {
                              wantRecord.value = false;
                            });
                          },
                          child: const Text('later'),
                        ),
                        TextButton(
                          onPressed: () {
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
                  );
                },
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
              ValueListenableBuilder<bool>(
                valueListenable: wantInference,
                builder: (context, value, child) {
                  return Visibility(
                    visible: value,
                    child: AlertDialog(
                      title: const Text('Read this book with your voice'),
                      content: const Text(
                        "You can make this book with your voice. \nDo you want to make it?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Future.delayed(const Duration(seconds: 1), () {
                              wantInference.value = false;
                            });
                          },
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 1초 후에 다음 페이지로 이동
                            startInference(token);
                            cvi = voices[0]['contentVoiceId'];
                            //   setState(() {
                            wantInference.value = false;
                            // });
                          },
                          child: const Text('YES'),
                        ),
                      ],
                    ),
                  );
                },
              )
            ]));
      }
    });
  }
}
