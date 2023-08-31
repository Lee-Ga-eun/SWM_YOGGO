import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/bookIntro/view/book_intro.dart';
import 'package:yoggo/component/home/viewModel/home_screen_book_model.dart';
import 'package:yoggo/component/sign.dart';
import 'package:yoggo/component/sub.dart';
import 'package:yoggo/component/rec_info.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yoggo/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bookIntro/viewModel/book_intro_cubit.dart';
import '../../sign_and.dart';
import '../../voice.dart';
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
  bool wantDelete = false;
  double dropdownHeight = 0.0;
  bool isDataFetched = false; // 데이터를 받아온 여부를 나타내는 플래그
  bool showOverlay = false; // Initially show the overlay
  bool showBanner = false;
  bool showFairy = false;
  bool showToolTip = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    super.initState();
    getToken();
    _checkFirstTimeAccess(); // 앱 최초 사용 접속 : 온보딩 화면 보여주기
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Amplitude amplitude = Amplitude.getInstance();

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      //userInfo(token);
      //getVoiceInfo(token);
    });
  }

  Future<void> _checkFirstTimeAccess() async {
    // 앱 최초 사용 접속 : 온보딩 화면 보여주기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool haveClickedBook = prefs.getBool('haveClickedBook') ?? false;
    // bool haveClickedFairy = prefs.getBool('haveClickedFairy') ?? false;
    print(prefs.getBool('haveClickedBook'));
    if (haveClickedBook) {
      setState(() {
        showFairy = haveClickedBook;
      });
      print('showFairy');
    }
    if (isFirstTime) {
      setState(() {
        showOverlay = true;
      });
      // Set isFirstTime to false after showing overlay
      await prefs.setBool('isFirstTime', false);
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await _googleSignIn.disconnect();
  }

  void deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tokens = prefs.getString('token')!;
    var response = await http.get(
      Uri.parse('https://yoggo-server.fly.dev/auth/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tokens',
      },
    );
    if (response.statusCode == 200) {
      logout();
    }
  }

  void pointFunction() {
    // AppBar 아이콘 클릭
  }

  @override
  Widget build(BuildContext context) {
    //final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    _sendHomeViewEvent();

    return BlocProvider(
        create: (context) =>
            DataCubit()..loadHomeBookData(), // DataCubit 생성 및 데이터 로드
        // child: DataList(
        //   record:
        //   purchase:
        // ),
        //final userCubit = context.watch<UserCubit>();
        //final userState = userCubit.state;
        child: BlocBuilder<DataCubit, List<HomeScreenBookModel>>(
          builder: (context, state) {
            if (state.isEmpty) {
              _sendHomeLoadingViewEvent();
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
                                left: 3 * SizeConfig.defaultSize!,
                                //right: 3 * SizeConfig.defaultSize!,
                              ),
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
                                left: 3 * SizeConfig.defaultSize!,
                              ),
                              //right: 3 * SizeConfig.defaultSize!),
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
                                              _sendHbgVoiceBoxClickEvent();
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
                                                          userCubit.fetchUser();
                                                          _sendHbgVoiceClickEvent();
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
                                              _sendHbgAddVoiceClickEvent();
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
                                            behavior: HitTestBehavior.opaque,
                                            child: Padding(
                                              padding: EdgeInsets.all(0.5 *
                                                  SizeConfig.defaultSize!),
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
                                            ),
                                            onTap: () {
                                              _sendSignOutClickEvent();

                                              setState(() {
                                                showSignOutConfirmation =
                                                    !showSignOutConfirmation; // dropdown 상태 토글
                                              });
                                            },
                                          )
                                        : GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            child: Padding(
                                              padding: EdgeInsets.all(0.2 *
                                                  SizeConfig.defaultSize!),
                                              child: Container(
                                                  child: Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 1.8 *
                                                      SizeConfig.defaultSize!,
                                                  fontFamily: 'Molengo',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              )),
                                            ),
                                            onTap: () {
                                              _sendSignInClickEvent();

                                              // dropdown 상태 토글
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Platform.isIOS
                                                            ? const Login()
                                                            : const LoginAnd()),
                                              );
                                            }),
                                    //    userState.login && showSignOutConfirmation
                                    userState.login && showSignOutConfirmation
                                        ? GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              _sendSignOutReallyClickEvent();
                                              logout();
                                              userCubit.logout();
                                              OneSignal.shared
                                                  .removeExternalUserId();
                                              _scaffoldKey.currentState
                                                  ?.closeDrawer();
                                              setState(() {
                                                showSignOutConfirmation =
                                                    !showSignOutConfirmation;
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.all(0.5 *
                                                  SizeConfig.defaultSize!),
                                              padding: EdgeInsets.all(0.3 *
                                                  SizeConfig.defaultSize!),
                                              color: Colors
                                                  .transparent, // 배경 터치 가능하게 하려면 배경 색상을 투명하게 설정
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
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 1 * SizeConfig.defaultSize!,
                                    ),
                                    userState.login
                                        ? GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            child: Padding(
                                              padding: EdgeInsets.all(0.5 *
                                                  SizeConfig.defaultSize!),
                                              child: Text(
                                                'Delete Account',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 1.8 *
                                                      SizeConfig.defaultSize!,
                                                  fontFamily: 'Molengo',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _scaffoldKey.currentState
                                                    ?.closeDrawer();
                                                wantDelete = true;
                                              });
                                            },
                                          )
                                        : Container(),
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
                body: Stack(children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/images/bkground.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      top: false,
                      minimum: EdgeInsets.only(
                          left: 2 * SizeConfig.defaultSize!,
                          right: 2 * SizeConfig.defaultSize!),
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
                                      _sendHbgClickEvent();
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
                                userState.record && userState.purchase
                                    ? Container()
                                    //     : Expanded(
                                    : showFairy
                                        ? Positioned(
                                            top: SizeConfig.defaultSize! * 1.2,
                                            right:
                                                SizeConfig.defaultSize! * 0.5,
                                            child: Container(
                                                child: GestureDetector(
                                              onTap: () async {
                                                _sendToolTipClickEvent();
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                setState(() {
                                                  showToolTip = false;
                                                });
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
                                              child: Transform(
                                                  // 좌우반전
                                                  alignment: Alignment.center,
                                                  transform: Matrix4.identity()
                                                    ..scale(-1.0, 1.0),
                                                  child: Image.asset(
                                                    'lib/images/fairy.png',
                                                    width: 50,
                                                    height: 50,
                                                  )),
                                            )))
                                        : Container(),
                              ],
                            ),
                          ),
                          // SizedBox(
                          //   height: SizeConfig.defaultSize! * 1.5,
                          // ),
                          // 배너 종료
                          Expanded(
                            flex: SizeConfig.defaultSize!.toInt() * 4,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: SizeConfig.defaultSize! * 29,
                                    child: BlocProvider(
                                      create: (context) => DataCubit()
                                        ..loadHomeBookData(), // DataCubit 생성 및 데이터 로드
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        // itemCount: state.length,
                                        itemCount: 4,
                                        itemBuilder: (context, index) {
                                          final book = state[index];
                                          return GestureDetector(
                                            onTap: () async {
                                              _sendBookClickEvent(book.id);
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setBool(
                                                  'haveClickedBook', true);
                                              setState(() {
                                                showFairy = true;
                                              });
                                              // showFairy = true;
                                              // print(showFairy);
                                              book.title !=
                                                      'The Three Little Pigs'
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            BlocProvider(
                                                          create: (context) =>
                                                              // BookIntroCubit(),
                                                              // DataCubit()..loadHomeBookData()
                                                              BookIntroCubit()
                                                                ..loadBookIntroData(
                                                                    book.id),
                                                          child: BookIntro(
                                                            title: book.title,
                                                            thumb:
                                                                book.thumbUrl,
                                                            id: book.id,
                                                            summary:
                                                                book.summary,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            userState.purchase
                                                                ? const RecInfo()
                                                                : const Purchase(),
                                                      ));
                                            },
                                            child: book.title ==
                                                    'The Three Little Pigs' //제목이 성냥팔이 소녀일 경우 ==> 나중에는, lock=true인 경우
                                                ? Column(
                                                    children: [
                                                      Hero(
                                                        tag: book.id,
                                                        child: Container(
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              22,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            child: Stack(
                                                                children: [
                                                                  CachedNetworkImage(
                                                                    imageUrl: book
                                                                        .thumbUrl,
                                                                  ),
                                                                  Container(
                                                                    width: SizeConfig
                                                                            .defaultSize! *
                                                                        22,
                                                                    color: const Color.fromARGB(
                                                                            255,
                                                                            220,
                                                                            220,
                                                                            220)
                                                                        .withOpacity(
                                                                            0.6),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Image
                                                                        .asset(
                                                                      'lib/images/locked.png',
                                                                      width: 80,
                                                                    ),
                                                                  )
                                                                ]),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .defaultSize! *
                                                            1,
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                                .defaultSize! *
                                                            20,
                                                        child: Text(
                                                          book.title,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'GenBkBasR',
                                                            fontSize: SizeConfig
                                                                    .defaultSize! *
                                                                2,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      Hero(
                                                        tag: book.id,
                                                        child: Container(
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              22,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  book.thumbUrl,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: SizeConfig
                                                                .defaultSize! *
                                                            1,
                                                      ),
                                                      SizedBox(
                                                        width: SizeConfig
                                                                .defaultSize! *
                                                            20,
                                                        child: Text(
                                                          book.title,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'GenBkBasR',
                                                            fontSize: SizeConfig
                                                                    .defaultSize! *
                                                                2,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
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
                                      ),
                                    ),
                                  ), //첫 줄 종료
                                  SizedBox(
                                    //두 번째 줄 시작
                                    height: SizeConfig.defaultSize! * 36,
                                    child: BlocProvider(
                                        create: (context) => DataCubit()
                                          ..loadHomeBookData(), // DataCubit 생성 및 데이터 로드
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: state.length - 4,
                                          itemBuilder: (context, index) {
                                            final book = state[index + 4];
                                            return GestureDetector(
                                              onTap: () async {
                                                _sendBookClickEvent(book.id);
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.setBool(
                                                    'haveClickedBook', true);
                                                setState(() {
                                                  showFairy = true;
                                                });
                                                // showFairy = true;
                                                // print(showFairy);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          userState.purchase
                                                              ? const RecInfo()
                                                              : const Purchase(),
                                                    )
                                                    //   BlocProvider(
                                                    // create: (context) =>
                                                    //     // BookIntroCubit(),
                                                    //     // DataCubit()..loadHomeBookData()
                                                    //     BookIntroCubit()
                                                    //       ..loadBookIntroData(
                                                    //           book.id),
                                                    // child: BookIntro(
                                                    //   title: book.title,
                                                    //   thumb: book.thumbUrl,
                                                    //   id: book.id,
                                                    //   summary: book.summary,
                                                    // ),
                                                    //   ),

                                                    );
                                              },
                                              child: Column(
                                                children: [
                                                  Hero(
                                                    tag: book.id,
                                                    child: Container(
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      height: SizeConfig
                                                              .defaultSize! *
                                                          22,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: Stack(children: [
                                                          CachedNetworkImage(
                                                            imageUrl:
                                                                book.thumbUrl,
                                                          ),
                                                          Container(
                                                            width: SizeConfig
                                                                    .defaultSize! *
                                                                22,
                                                            color: const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    220,
                                                                    220,
                                                                    220)
                                                                .withOpacity(
                                                                    0.6),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Image.asset(
                                                              'lib/images/locked.png',
                                                              width: 80,
                                                            ),
                                                          )
                                                        ]),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: SizeConfig
                                                            .defaultSize! *
                                                        1,
                                                  ),
                                                  SizedBox(
                                                    width: SizeConfig
                                                            .defaultSize! *
                                                        20,
                                                    child: Text(
                                                      book.title,
                                                      style: TextStyle(
                                                        fontFamily: 'GenBkBasR',
                                                        fontSize: SizeConfig
                                                                .defaultSize! *
                                                            2,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
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
                  Visibility(
                    visible: wantDelete,
                    child: AlertDialog(
                      title: const Text('Delete Account'),
                      content:
                          const Text('Do you want to DELETE your account?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // 1초 후에 다음 페이지로 이동
                            userCubit.logout();
                            OneSignal.shared.removeExternalUserId();
                            deleteAccount();
                            Future.delayed(const Duration(seconds: 1), () {
                              setState(() {
                                wantDelete = false;
                              });
                            });
                          },
                          child: const Text('YES'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 1초 후에 다음 페이지로 이동
                            setState(() {
                              wantDelete = false;
                            });
                          },
                          child: const Text('No'),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   color: Colors.white.withOpacity(0.6),
                  //   child: GestureDetector(
                  //     onTap: ,
                  //   ),
                  // )
                  GestureDetector(
                    onTap: () {
                      _sendHomeFirstClick();
                      setState(() {
                        // Toggle the value of showOverlay when the overlay is tapped
                        showOverlay = !showOverlay;
                      });
                    },
                    child: Visibility(
                      visible: showOverlay,
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.white.withOpacity(0.6),
                          ),
                          SafeArea(
                            child: Column(
                              children: [
                                Expanded(
                                  flex: SizeConfig.defaultSize!.toInt(),
                                  child: Container(),
                                ),
                                Expanded(
                                    flex: SizeConfig.defaultSize!.toInt() * 2,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          left: SizeConfig.defaultSize!,
                                          right: SizeConfig.defaultSize!,
                                          // top: SizeConfig.defaultSize! * 10,
                                          // 안내 글씨
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  const Color.fromARGB(
                                                      255, 255, 169, 26),
                                                ),
                                                padding: MaterialStateProperty
                                                    .all<EdgeInsetsGeometry>(
                                                  EdgeInsets.symmetric(
                                                    vertical: SizeConfig
                                                            .defaultSize! *
                                                        3, // 수직 방향 패딩
                                                  ),
                                                ),
                                              ),
                                              onPressed: null,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                      width: SizeConfig
                                                              .defaultSize! *
                                                          25),
                                                  Text(
                                                    'Hi~ You can read all the books for free. \nClick on the book you want to read!',
                                                    style: TextStyle(
                                                        fontFamily: 'Molengo',
                                                        color: Colors.black,
                                                        fontSize: SizeConfig
                                                                .defaultSize! *
                                                            2.5),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: SizeConfig.defaultSize! * 1,
                                          bottom: SizeConfig.defaultSize! * 5,
                                          child: Image.asset(
                                            'lib/images/fairy.png',
                                            width: SizeConfig.defaultSize! * 20,
                                          ),
                                        ),
                                        Positioned(
                                          left: SizeConfig.defaultSize! * 42,
                                          top: SizeConfig.defaultSize! * 2,
                                          child: Image.asset(
                                            'lib/images/overlayClick.png',
                                            width: SizeConfig.defaultSize! * 10,
                                          ),
                                        ),
                                      ],
                                    )),
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
                    //   ),
                    ),
              );
            }
          },
        ));
    //  ),
    //],
    //);
  }

  Future<void> _sendSignOutReallyClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_out_really_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'sign_out_really_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendSignOutClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_out_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'sign_out_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendSignInClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'sign_in_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'sign_in_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgVoiceClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_voice_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'hbg_voice_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgAddVoiceClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_add_voice_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'hbg_add_voice_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgVoiceBoxClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_voice_box_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'hbg_voice_box_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgNameClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_name_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'hbg_name_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHomeViewEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'home_view',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'home_view',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookClickEvent(contentId) async {
    try {
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

  Future<void> _sendBannerClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'banner_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'banner_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendFairyClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'fairy_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'fairy_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendToolTipClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'tooltip_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'tooltip_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHbgClickEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'hbg_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'hbg_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHomeLoadingViewEvent() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'home_loading_view',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'home_loading_view',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendHomeFirstClick() async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'home_first_click',
        parameters: <String, dynamic>{},
      );
      await amplitude.logEvent(
        'home_first_click',
        eventProperties: {},
      );
    } catch (e) {
      print('Failed to log event: $e');
    }
  }
}
