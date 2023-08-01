import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/login.dart';
import 'package:yoggo/component/sub.dart';
import 'package:yoggo/component/rec_info.dart';
import 'package:yoggo/component/book_intro.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yoggo/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../voice_profile.dart';
import '../viewModel/home_screen_cubit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../globalCubit/user/user_cubit.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // late Future<List<bookModel>> webtoons;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late String token;
  late int userId;
  bool showEmail = false;
  bool showSignOutConfirmation = false;
  double dropdownHeight = 0.0;
  bool isDataFetched = false; // 데이터를 받아온 여부를 나타내는 플래그

  @override
  void initState() {
    super.initState();
    getToken();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Amplitude amplitude = Amplitude.getInstance(instanceName: "SayIT");

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      //userInfo(token);
      //getVoiceInfo(token);
    });
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await _googleSignIn.disconnect();
  }

  void pointFunction() {
    // AppBar 아이콘 클릭
  }

  @override
  Widget build(BuildContext context) {
    //final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    _sendHomeViewEvent(userState.purchase, userState.record);
    SizeConfig().init(context);
    return BlocProvider(
        create: (context) => DataCubit()..loadData(), // DataCubit 생성 및 데이터 로드
        // child: DataList(
        //   record: userState.record,
        //   purchase: userState.purchase,
        // ),
        //final userCubit = context.watch<UserCubit>();
        //final userState = userCubit.state;
        child: BlocBuilder<DataCubit, List<BookModel>>(
          builder: (context, state) {
            if (state.isEmpty) {
              _sendHomeLoadingViewEvent(userState.purchase, userState.record);
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/images/bkground.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: const Color.fromARGB(255, 255, 169, 26),
                    size: SizeConfig.defaultSize! * 10,
                  ),
                ),
              );
            } else {
              return Scaffold(
                key: _scaffoldKey,
                drawer: SizedBox(
                  width: 33 * SizeConfig.defaultSize!,
                  child: Drawer(
                      child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/images/bkground.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Container(
                            width: 30 * SizeConfig.defaultSize!,
                            height: 11 * SizeConfig.defaultSize!,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5)),
                            child: SafeArea(
                              minimum: EdgeInsets.only(
                                  left: 3 * SizeConfig.defaultSize!),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: SizeConfig.defaultSize! * 3),
                                  Text(
                                    ' Welcome! ',
                                    style: TextStyle(
                                        fontSize: SizeConfig.defaultSize! * 1.8,
                                        fontFamily: 'Molengo'),
                                  ),
                                  SizedBox(height: SizeConfig.defaultSize!),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: SizeConfig.defaultSize! * 1),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.account_circle,
                                          size: SizeConfig.defaultSize! * 2.3,
                                        ),
                                        SizedBox(
                                          width: SizeConfig.defaultSize! * 0.5,
                                        ),
                                        Text(
                                          userState.userName,
                                          style: TextStyle(
                                              fontSize:
                                                  SizeConfig.defaultSize! *
                                                      1.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        Column(
                          children: [
                            SafeArea(
                              minimum: EdgeInsets.only(
                                  left: 3 * SizeConfig.defaultSize!),
                              child: ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ),
                                    SizedBox(
                                      height: 2 * SizeConfig.defaultSize!,
                                    ),
                                    Text(
                                      'Voice Profile',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 1.8 * SizeConfig.defaultSize!,
                                        fontFamily: 'Molengo',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 1 * SizeConfig.defaultSize!,
                                    ),
                                    userState.record && userState.purchase
                                        ? GestureDetector(
                                            onTap: () {
                                              _sendHbgVoiceBoxClickEvent(
                                                  userState.purchase,
                                                  userState.record);
                                            },
                                            child: SizedBox(
                                              width:
                                                  23 * SizeConfig.defaultSize!,
                                              height:
                                                  11 * SizeConfig.defaultSize!,
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    child: Container(
                                                      width: 23 *
                                                          SizeConfig
                                                              .defaultSize!,
                                                      height: 11 *
                                                          SizeConfig
                                                              .defaultSize!,
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                      left: 1.2 *
                                                          SizeConfig
                                                              .defaultSize!,
                                                      top: 1.5 *
                                                          SizeConfig
                                                              .defaultSize!,
                                                      // child: Transform.translate(
                                                      //     offset: Offset(
                                                      //         0.5,
                                                      //         -0.7 *
                                                      //             SizeConfig.defaultSize!),
                                                      child: Image.asset(
                                                        'lib/images/icons/${userState.voiceIcon}-c.png',
                                                        height: SizeConfig
                                                                .defaultSize! *
                                                            8,
                                                      )),
                                                  Positioned(
                                                    left: 9.5 *
                                                        SizeConfig.defaultSize!,
                                                    top: 2.3 *
                                                        SizeConfig.defaultSize!,
                                                    child: SizedBox(
                                                      width: 12.2 *
                                                          SizeConfig
                                                              .defaultSize!,
                                                      height: 2 *
                                                          SizeConfig
                                                              .defaultSize!,
                                                      child: Text(
                                                        userState.voiceName!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 2 *
                                                              SizeConfig
                                                                  .defaultSize!,
                                                          fontFamily: 'Molengo',
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 10.2 *
                                                        SizeConfig.defaultSize!,
                                                    top: 6 *
                                                        SizeConfig.defaultSize!,
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          _sendHbgVoiceClickEvent(
                                                              userState
                                                                  .purchase,
                                                              userState.record);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const VoiceProfile(),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                            width: 11 *
                                                                SizeConfig
                                                                    .defaultSize!,
                                                            height: 3 *
                                                                SizeConfig
                                                                    .defaultSize!,
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: const Color(
                                                                  0xFFFFA91A),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                              'Edit this voice',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 1.4 *
                                                                    SizeConfig
                                                                        .defaultSize!,
                                                                fontFamily:
                                                                    'Molengo',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                            )))),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              _sendHbgVoiceClickEvent(
                                                  userState.purchase,
                                                  userState.record);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      userState.purchase
                                                          ? const RecInfo()
                                                          : const Purchase(),
                                                ),
                                              );
                                            },
                                            child: Container(
                                                width: 27 *
                                                    SizeConfig.defaultSize!,
                                                height:
                                                    4 * SizeConfig.defaultSize!,
                                                decoration: ShapeDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size:
                                                      SizeConfig.defaultSize! *
                                                          2.5,
                                                  color:
                                                      const Color(0xFFFFA91A),
                                                ))),

                                    SizedBox(
                                      height: 2 * SizeConfig.defaultSize!,
                                    ),
                                    // IconButton(
                                    //     onPressed: () {
                                    //       Navigator.push(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //           builder: (context) => CheckVoice(
                                    //             infenrencedVoice: '48',
                                    //           ),
                                    //         ),
                                    //       );
                                    //     },
                                    //     icon: const Icon(Icons.check)),

                                    userState.login
                                        ? GestureDetector(
                                            child: Text(
                                              'Sign Out',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 1.8 *
                                                    SizeConfig.defaultSize!,
                                                fontFamily: 'Molengo',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            onTap: () {
                                              _sendSignOutClickEvent(
                                                  userState.purchase,
                                                  userState.record);
                                              setState(() {
                                                showSignOutConfirmation =
                                                    !showSignOutConfirmation; // dropdown 상태 토글
                                              });
                                            },
                                          )
                                        : GestureDetector(
                                            child: Text(
                                              'Sign In',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 1.8 *
                                                    SizeConfig.defaultSize!,
                                                fontFamily: 'Molengo',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            onTap: () {
                                              _sendSignOutClickEvent(
                                                  userState.purchase,
                                                  userState.record);
                                              // dropdown 상태 토글
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Login(),
                                                  ));
                                            }),
                                    //    userState.login && showSignOutConfirmation
                                    userState.login && showSignOutConfirmation
                                        ? GestureDetector(
                                            child: Transform.translate(
                                                offset: Offset(
                                                    0.5 *
                                                        SizeConfig.defaultSize!,
                                                    0.5 *
                                                        SizeConfig
                                                            .defaultSize!),
                                                child: Text(
                                                  'Do you want to Sign Out?',
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFF599FED),
                                                    fontSize: 1.2 *
                                                        SizeConfig.defaultSize!,
                                                    fontFamily: 'Molengo',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                )),
                                            //),
                                            onTap: () {
                                              _sendSignOutReallyClickEvent(
                                                  userState.purchase,
                                                  userState.record);
                                              logout();
                                              userCubit.logout();
                                              OneSignal.shared
                                                  .removeExternalUserId();
                                              _scaffoldKey.currentState
                                                  ?.closeDrawer();
                                              setState(() {
                                                showSignOutConfirmation =
                                                    !showSignOutConfirmation; // dropdown 상태 토글
                                              }); //고민
                                            },
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
                ),
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
                    minimum: EdgeInsets.only(left: 3 * SizeConfig.defaultSize!),
                    child: Column(
                      children: [
                        Expanded(
                          flex: SizeConfig.defaultSize!.toInt(),
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
                                //left: 20,
                                top: SizeConfig.defaultSize! * 2,
                                child: InkWell(
                                  onTap: () {
                                    //     print("열림");
                                    _sendHbgClickEvent(
                                        userState.purchase, userState.record);
                                    _scaffoldKey.currentState?.openDrawer();
                                  },
                                  child: Image.asset(
                                    'lib/images/hamburger.png',
                                    width: 3.5 *
                                        SizeConfig.defaultSize!, // 이미지의 폭 설정
                                    height: 3.5 *
                                        SizeConfig.defaultSize!, // 이미지의 높이 설정
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: SizeConfig.defaultSize! * 1.5,
                        // ),
                        userState.record && userState.purchase
                            ? Container()
                            //     : Expanded(
                            : Expanded(
                                // 녹음까지 마치지 않은 사용자 - 위에 배너 보여줌
                                flex: SizeConfig.defaultSize!.toInt() * 1,
                                child: Column(
                                  children: [
                                    // 구매한 사용자면 보여지게, 구매하지 않은 사용자면 보여지지 않게
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 0 * SizeConfig.defaultSize!,
                                          right: 0 * SizeConfig.defaultSize!),
                                      child: GestureDetector(
                                        onTap: () {
                                          _sendBannerClickEvent(
                                              userState.purchase,
                                              userState.record);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  userState.purchase
                                                      ? const RecInfo()
                                                      : const Purchase(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            color: Color(0xFFFFA91A),
                                            //   border: Border.all(
                                            //   color: const Color.fromARGB(255, 255, 169, 26)),
                                          ),
                                          // color: Colors.white,
                                          height: SizeConfig.defaultSize! * 4,
                                          child: Center(
                                            child: Text(
                                              'Want to read a book in your voice?',
                                              style: TextStyle(
                                                  fontSize: 2 *
                                                      SizeConfig.defaultSize!,
                                                  fontFamily: 'Molengo',
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ), // 배너 종료
                        Expanded(
                          flex: SizeConfig.defaultSize!.toInt() * 4,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: SizeConfig.defaultSize! * 36,
                                  child: BlocProvider(
                                      create: (context) => DataCubit()
                                        ..loadData(), // DataCubit 생성 및 데이터 로드
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.length,
                                        itemBuilder: (context, index) {
                                          final book = state[index];
                                          return GestureDetector(
                                            onTap: () {
                                              _sendBookClickEvent(book.id);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BookIntro(
                                                    title: book.title,
                                                    thumb: book.thumbUrl,
                                                    id: book.id,
                                                    summary: book.summary,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                Hero(
                                                  tag: book.id,
                                                  child: Container(
                                                    clipBehavior: Clip.hardEdge,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    height: SizeConfig
                                                            .defaultSize! *
                                                        22,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: CachedNetworkImage(
                                                        imageUrl: book.thumbUrl,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          1,
                                                ),
                                                SizedBox(
                                                  width:
                                                      SizeConfig.defaultSize! *
                                                          20,
                                                  child: Text(
                                                    book.title,
                                                    style: TextStyle(
                                                      fontFamily: 'BreeSerif',
                                                      fontSize: SizeConfig
                                                              .defaultSize! *
                                                          1.6,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            SizedBox(
                                                width: 2 *
                                                    SizeConfig.defaultSize!),
                                      )),
                                ),
                                // 아래 줄에 또 다른 책을 추가하고 싶으면 주석을 해지하면 됨
                                // Container(
                                //   color: Colors.yellow,
                                //   height: 300,
                                //   child: const Center(
                                //     child: Text(
                                //       'Scrollable Content 2',
                                //       style: TextStyle(fontSize: 24),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //   ),
              );
            }
          },
        ));
    //  ),
    //],
    //);
  }

  Future<void> _sendSignOutReallyClickEvent(purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_out_really_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'sign_out_really_click',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendSignOutClickEvent(purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_out_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'sign_out_click',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgVoiceClickEvent(purchase, record) async {
    try {
      print("_sendHbgVoiceClickEvent");
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_voice_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'hbg_voice_click',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgVoiceBoxClickEvent(purchase, record) async {
    print("_sendHbgVoiceBoxClickEvent");
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_voice_box_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'hbg_voice_box_click',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgMeClickEvent(purchase, record) async {
    try {
      print("_sendHbgMeClickEvent");
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_me_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'hbg_me_click',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHomeViewEvent(purchase, record) async {
    try {
      print("_sendHomeViewEvent");
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'home_view',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'home_view',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookClickEvent(contentId) async {
    try {
      print("_sendBookClickEvent");
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_click',
        parameters: <String, dynamic>{
          'contentId': contentId,
        },
      );
      await amplitude.logEvent(
        'book_click',
        eventProperties: {
          'contentId': contentId,
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBannerClickEvent(purchase, record) async {
    try {
      print("_sendBannerClickEvent");
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'banner_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'banner_click',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgClickEvent(purchase, record) async {
    try {
      print("_sendHbgClickEvent");
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'hbg_click',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHomeLoadingViewEvent(purchase, record) async {
    try {
      print("_sendHomeLoadingViewEvent");
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'home_loading_view',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'home_loading_view',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }
}
