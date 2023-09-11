import 'package:amplitude_flutter/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/bookIntro/view/book_intro.dart';
import 'package:yoggo/component/globalCubit/user/user_state.dart';
import 'package:yoggo/component/home/viewModel/home_screen_book_model.dart';
import 'package:yoggo/component/sign.dart';
// import 'package:yoggo/component/sub.dart';
import 'package:yoggo/component/shop.dart';
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
import 'package:intl/intl.dart';

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
  // 받을 수 있는 포인트 day : availableGetPoint // 1일차, 2일차 ...
  // 마지막으로 받은 날짜: lastPointYMD // 2023년9월22일
  // 마지막으로 받은 포인트의 일수: lastPointDay --> 1일차, 2일차, 3일차... --> 마지막 기록이 1일차이면 2일차 포인트를 받게 해야한다
  late int availableGetPoint;
  late String lastPointYMD;
  int lastPointDay = -1;
  String formattedTime = '';
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    super.initState();
    getToken();
    _checkFirstTimeAccess(); // 앱 최초 사용 접속 : 온보딩 화면 보여주기
    Future.delayed(Duration.zero, () async {
      await saveRewardStatus();
    });
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

  Future<void> saveRewardStatus() async {
    DateTime currentTime = DateTime.now();

    formattedTime = DateFormat('yyyy-MM-dd').format(currentTime);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('availableGetPoint') == null) {
      // 첫사용자인 경우
      prefs.setInt('availableGetPoint', 0); // 1일차 포인트를 받을 수 있음
      availableGetPoint = 0;
    } else {
      availableGetPoint = prefs.getInt('availableGetPoint')!;
      print('aaa $availableGetPoint');
    }

    if (prefs.getString('lastPointYMD') == null) {
      // 내가 마지막으로 받은 날짜
      prefs.setString('lastPointYMD', formattedTime); //
      lastPointYMD = formattedTime;
    } else {
      lastPointYMD = prefs.getString('lastPointYMD')!;
    }
    if (prefs.getInt('lastPointDay') == null) {
      // 내가 마지막으로 받은 일차
      prefs.setInt('lastPointDay', 0); // 일차
      lastPointDay = 0;
    } else {
      lastPointDay = prefs.getInt('lastPointDay')!;
    }
  }

  bool openCalendar = false;

  void _openCalendarFunc() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime currentTime = DateTime.now();
    formattedTime = DateFormat('yyyy-MM-dd').format(currentTime);
    // 받을 수 있는 포인트 day : availableGetPoint // 1일차, 2일차 ...
    // 마지막으로 받은 날짜: lastPointYMD // 2023년9월22일
    // 마지막으로 받은 포인트의 일수: lastPointDay --> 1일차, 2일차, 3일차... --> 마지막 기록이 1일차이면 2일차 포인트를 받게 해야한다

    // if (prefs.getInt('availableGetPoint') == null) {
    //   // 첫사용자인 경우
    //   prefs.setInt('availableGetPoint', 1); // 1일차 포인트를 받을 수 있음
    // } else {
    //   availableGetPoint = prefs.getInt('availableGetPoint')!;
    // }

    // if (prefs.getString('lastPointYMD') == null) {
    //   // 내가 마지막으로 받은 날짜
    //   prefs.setString('lastPointYMD', formattedTime); //
    // } else {
    //   lastPointYMD = prefs.getString('lastPointYMD')!;
    // }
    // if (prefs.getInt('lastPointDay') == null) {
    //   // 내가 마지막으로 받은 일차
    //   prefs.setInt('lastPointDay', 0); // 일차
    // } else {
    //   lastPointDay = prefs.getInt('lastPointDay')!;
    // }

    // lastPointDay가 7이면
    print('lastPointDay $lastPointDay');
    if (lastPointDay == 7 && prefs.getString('lastPointYMD') != formattedTime) {
      //저장된 lastPointDay가 7이고 다음 날 들어왔으면 --> 즉 포인트 다시 리셋되어야 하면
      setState(() {
        lastPointDay = 0;
        prefs.setInt('lastPointDay', 0);
        prefs.setInt('availableGetPoint', 0);
        lastPointDay = prefs.getInt('lastPointDay')!;
        availableGetPoint = prefs.getInt('availableGetPoint')!;
      });
    }

    setState(() {
      openCalendar = true;
    });
  }

  void _closeCalendarFunc() {
    setState(() {
      openCalendar = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(lastPointDay);
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
                  child: _Drawer(userState, userCubit, context),
                ),
                body: Stack(children: [
                  if (openCalendar)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _openCalendarFunc,
                        child: Container(
                          color: const Color.fromARGB(255, 251, 251, 251)
                              .withOpacity(0.5), // 반투명 배경색 설정
                        ),
                      ),
                    ),
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
                                // if (openCalendar)
                                //   Positioned.fill(
                                //     child: GestureDetector(
                                //       onTap: _openCalendarFunc,
                                //       child: Container(
                                //         color: const Color.fromARGB(
                                //                 255, 251, 251, 251)
                                //             .withOpacity(0.5), // 반투명 배경색 설정
                                //       ),
                                //     ),
                                //   ),
                                Positioned(
                                  right: 70,
                                  top: SizeConfig.defaultSize! * 2,
                                  child: InkWell(
                                    onTap: () {
                                      _openCalendarFunc();
                                    },
                                    child: Image.asset(
                                      'lib/images/calendar.png',
                                      width: 4.7 *
                                          SizeConfig.defaultSize!, // 이미지의 폭 설정
                                      height: 4.7 *
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
                                                          const Purchase()
                                                      // userState.purchase
                                                      //     ? const RecInfo()
                                                      //     : const Purchase(),
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
                            //첫 줄 시작
                            // 즉 purhcase true/false로 나누고
                            // true면 전부 푸는 코드, false면 title이 백설공주 || title이 성냥팔이소녀 || lock=false
                            // userState의 purchase==true이면 잠금 없음
                            // purchase가 false라면?
                            // 백설공주, 성냥팔이소녀는 잠금 해제
                            // lock!=true라면? (코인으로 산 경우) 잠금 해제
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
                                              // --------
                                              userState.purchase == true ||
                                                      book.lock == false ||
                                                      (book.title ==
                                                              'Snow White and the Seven Dwarfs' ||
                                                          book.title ==
                                                              'The Little Match Girl') // 구독자인지 확인하기 and 포인트로 푼 책인지 확인하기
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
                                                      //구독자가 아니면 purchase로 보낸다?
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            userState.purchase
                                                                ? BlocProvider(
                                                                    create: (context) =>
                                                                        // BookIntroCubit(),
                                                                        // DataCubit()..loadHomeBookData()
                                                                        BookIntroCubit()..loadBookIntroData(book.id),
                                                                    child:
                                                                        BookIntro(
                                                                      title: book
                                                                          .title,
                                                                      thumb: book
                                                                          .thumbUrl,
                                                                      id: book
                                                                          .id,
                                                                      summary: book
                                                                          .summary,
                                                                    ),
                                                                  )
                                                                : const Purchase(),
                                                      ));
                                            }, //onTap 종료
                                            child: userState.purchase == true
                                                ? unlockedBook(book)
                                                : (book.title ==
                                                            'Snow White and the Seven Dwarfs' ||
                                                        book.title ==
                                                            'The Little Match Girl' ||
                                                        book.lock !=
                                                            true) // 사용자가 포인트로 책을 풀었거나, 무료 공개 책이면 lock 해제
                                                    ? unlockedBook(book)
                                                    : lockedBook(book), //구독자아님
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
                                                userState.purchase == true ||
                                                        book.lock == false ||
                                                        (book.title ==
                                                                'Snow White and the Seven Dwarfs' ||
                                                            book.title ==
                                                                'The Little Match Girl') // 구독자인지 확인하기 and 포인트로 푼 책인지 확인하기
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
                                                        //구독자가 아니면 purchase로 보낸다?
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              userState.purchase
                                                                  ? BlocProvider(
                                                                      create: (context) =>
                                                                          // BookIntroCubit(),
                                                                          // DataCubit()..loadHomeBookData()
                                                                          BookIntroCubit()..loadBookIntroData(book.id),
                                                                      child:
                                                                          BookIntro(
                                                                        title: book
                                                                            .title,
                                                                        thumb: book
                                                                            .thumbUrl,
                                                                        id: book
                                                                            .id,
                                                                        summary:
                                                                            book.summary,
                                                                      ),
                                                                    )
                                                                  : const Purchase(),
                                                        ));
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
                                              },
                                              child: userState.purchase == true
                                                  ? unlockedBook(book)
                                                  // : lockedBook(book),
                                                  : (book.title ==
                                                              'Snow White and the Seven Dwarfs' ||
                                                          book.title ==
                                                              'The Little Match Girl' ||
                                                          book.lock !=
                                                              true) // 사용자가 포인트로 책을 풀었거나, 무료 공개 책이면 lock 해제
                                                      ? unlockedBook(book)
                                                      : lockedBook(
                                                          book), //구독자아님
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
                  if (openCalendar)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _openCalendarFunc,
                        child: Stack(children: [
                          Container(
                            color: const Color.fromARGB(255, 251, 251, 251)
                                .withOpacity(0.5), // 반투명 배경색 설정
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: 55 * SizeConfig.defaultSize!,
                                height: 34 * SizeConfig.defaultSize!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            SizeConfig.defaultSize!)),
                                    color:
                                        const Color.fromARGB(255, 255, 255, 255)
                                            .withOpacity(1),
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: SizeConfig.defaultSize! * 6,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(
                                                  SizeConfig.defaultSize!),
                                              topLeft: Radius.circular(
                                                  SizeConfig.defaultSize!)),
                                          color: const Color.fromARGB(
                                              255, 255, 167, 26),
                                        ),
                                      ),
                                      Padding(
                                        //첫줄가로
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.defaultSize! * 0.4),
                                        child: Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              icon: const Icon(Icons.cancel),
                                              onPressed: _closeCalendarFunc,
                                            )),
                                      ),
                                      Padding(
                                        //첫번째줄가로
                                        padding: EdgeInsets.only(
                                            left: SizeConfig.defaultSize! * 6,
                                            top: SizeConfig.defaultSize! * 13),
                                        child: Container(
                                          height: SizeConfig.defaultSize! * 0.5,
                                          width: SizeConfig.defaultSize! * 30,
                                          color: const Color.fromARGB(
                                              255, 204, 165, 107),
                                        ),
                                      ),
                                      Padding(
                                        //두번째줄가로
                                        padding: EdgeInsets.only(
                                            left: SizeConfig.defaultSize! * 6,
                                            top: SizeConfig.defaultSize! * 20),
                                        child: Container(
                                          height: SizeConfig.defaultSize! * 0.5,
                                          width: SizeConfig.defaultSize! * 30,
                                          color: const Color.fromARGB(
                                              255, 204, 165, 107),
                                        ),
                                      ),
                                      Padding(
                                        //두번째줄세로
                                        padding: EdgeInsets.only(
                                            left: SizeConfig.defaultSize! * 36,
                                            top: SizeConfig.defaultSize! * 13),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 0.5,
                                          height: SizeConfig.defaultSize! * 7.5,
                                          color: const Color.fromARGB(
                                              255, 204, 165, 107),
                                        ),
                                      ),
                                      Padding(
                                        //두번째줄세로
                                        padding: EdgeInsets.only(
                                            left: SizeConfig.defaultSize! * 6,
                                            top: SizeConfig.defaultSize! * 20),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 0.5,
                                          height: SizeConfig.defaultSize! * 7,
                                          color: const Color.fromARGB(
                                              255, 204, 165, 107),
                                        ),
                                      ),
                                      Padding(
                                        //세번째줄가로
                                        padding: EdgeInsets.only(
                                            left: SizeConfig.defaultSize! * 6,
                                            top: SizeConfig.defaultSize! * 27),
                                        child: Container(
                                          height: SizeConfig.defaultSize! * 0.5,
                                          width: SizeConfig.defaultSize! * 40,
                                          color: const Color.fromARGB(
                                              255, 204, 165, 107),
                                        ),
                                      ), //선 끝
                                      //1일차
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.defaultSize! * 8,
                                            left: SizeConfig.defaultSize! * 3),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 10,
                                          height: SizeConfig.defaultSize! * 10,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 222, 220, 220),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        0.7,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: SizeConfig
                                                            .defaultSize! *
                                                        1.7,
                                                    right: SizeConfig
                                                            .defaultSize! *
                                                        1.7),
                                                child: lastPointDay >= 1
                                                    ? Image.asset(
                                                        'lib/images/completedOneCoin.png')
                                                    : Image.asset(
                                                        'lib/images/oneCoin.png',
                                                      ),
                                              ),
                                              Text(
                                                '100',
                                                style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .defaultSize! *
                                                        1.9,
                                                    fontFamily: 'Lillita'),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      //2일차
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.defaultSize! * 8,
                                            left: SizeConfig.defaultSize! * 16),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 10,
                                          height: SizeConfig.defaultSize! * 10,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 222, 220, 220),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        0.7,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: SizeConfig
                                                            .defaultSize! *
                                                        1.7,
                                                    right: SizeConfig
                                                            .defaultSize! *
                                                        1.7),
                                                child: lastPointDay >=
                                                        2 // 내가 마지막으로 받은 날짜 >= 2
                                                    ? Image.asset(
                                                        'lib/images/completedOneCoin.png')
                                                    : Image.asset(
                                                        'lib/images/oneCoin.png',
                                                      ),
                                              ),
                                              Text(
                                                '200',
                                                style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .defaultSize! *
                                                        1.9,
                                                    fontFamily: 'Lillita'),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      //3일차
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.defaultSize! * 8,
                                            left: SizeConfig.defaultSize! * 29),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 10,
                                          height: SizeConfig.defaultSize! * 10,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 222, 220, 220),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        0.7,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: SizeConfig
                                                            .defaultSize! *
                                                        1.7,
                                                    right: SizeConfig
                                                            .defaultSize! *
                                                        1.7),
                                                child: lastPointDay >= 3
                                                    ? Image.asset(
                                                        'lib/images/completedTwoCoins.png')
                                                    : Image.asset(
                                                        'lib/images/oneCoin.png',
                                                      ),
                                              ),
                                              Text(
                                                '200',
                                                style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .defaultSize! *
                                                        1.9,
                                                    fontFamily: 'Lillita'),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      //4일차
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.defaultSize! * 22,
                                            left: SizeConfig.defaultSize! * 3),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 10,
                                          height: SizeConfig.defaultSize! * 10,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 222, 220, 220),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        0.7,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: SizeConfig
                                                            .defaultSize! *
                                                        1.7,
                                                    right: SizeConfig
                                                            .defaultSize! *
                                                        1.7),
                                                child: lastPointDay >= 4
                                                    ? Image.asset(
                                                        'lib/images/completedTwoCoins.png')
                                                    : Image.asset(
                                                        'lib/images/oneCoin.png',
                                                      ),
                                              ),
                                              Text(
                                                '300',
                                                style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .defaultSize! *
                                                        1.9,
                                                    fontFamily: 'Lillita'),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      //5일차
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.defaultSize! * 22,
                                            left: SizeConfig.defaultSize! * 16),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 10,
                                          height: SizeConfig.defaultSize! * 10,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 222, 220, 220),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        0.7,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: SizeConfig
                                                            .defaultSize! *
                                                        1.7,
                                                    right: SizeConfig
                                                            .defaultSize! *
                                                        1.7),
                                                child: lastPointDay >= 5
                                                    ? Image.asset(
                                                        'lib/images/completedTwoCoins.png')
                                                    : Image.asset(
                                                        'lib/images/oneCoin.png',
                                                      ),
                                              ),
                                              Text(
                                                '400',
                                                style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .defaultSize! *
                                                        1.9,
                                                    fontFamily: 'Lillita'),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 6일차
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.defaultSize! * 22,
                                            left: SizeConfig.defaultSize! * 29),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 10,
                                          height: SizeConfig.defaultSize! * 10,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 222, 220, 220),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        0.7,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: SizeConfig
                                                            .defaultSize! *
                                                        1.7,
                                                    right: SizeConfig
                                                            .defaultSize! *
                                                        1.7),
                                                child: lastPointDay >= 6
                                                    ? Image.asset(
                                                        'lib/images/completedTwoCoins.png')
                                                    : Image.asset(
                                                        'lib/images/oneCoin.png',
                                                      ),
                                              ),
                                              Text(
                                                '500',
                                                style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .defaultSize! *
                                                        1.9,
                                                    fontFamily: 'Lillita'),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 7일차
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.defaultSize! * 8,
                                            left: SizeConfig.defaultSize! * 42),
                                        child: Container(
                                          width: SizeConfig.defaultSize! * 10,
                                          height: SizeConfig.defaultSize! * 24,
                                          decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 222, 220, 220),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height:
                                                    SizeConfig.defaultSize! *
                                                        0.7,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: SizeConfig
                                                            .defaultSize! *
                                                        1.7,
                                                    right: SizeConfig
                                                            .defaultSize! *
                                                        1.7),
                                                // 7일차 사용자?
                                                child: lastPointDay >= 7
                                                    ? Image.asset(
                                                        'lib/images/completedTwoCoins.png')
                                                    : Image.asset(
                                                        'lib/images/oneCoin.png',
                                                      ),
                                              ),
                                              Text(
                                                '1000',
                                                style: TextStyle(
                                                    fontSize: SizeConfig
                                                            .defaultSize! *
                                                        1.9,
                                                    fontFamily: 'Lilita'),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            DateTime currentDate =
                                                DateTime.now();
                                            print(currentDate);
                                            String formattedDate =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(currentDate);
                                            int tmp = prefs
                                                .getInt('availableGetPoint')!;
                                            final scores = [
                                              100,
                                              200,
                                              200,
                                              300,
                                              400,
                                              500,
                                              1000
                                            ];
                                            print(
                                                '다음 받을 수 있는 일차 $tmp'); // 다음날 받을 수 있는
                                            // print(
                                            //     '다음 날 받게 될 포인트 점수 ${scores[availableGetPoint - 1]}');
                                            print('마지막으로 받은 일차 $lastPointDay ');
                                            print('현재 날짜 $formattedDate');
                                            print(
                                                '마지막으로 받은 시간 ${prefs.getString('lastPointYMD')}');
                                            if (availableGetPoint == 0) {
                                              print("여길 또 오나?");
                                              // 딱 처음 사용자일 때만 적용됨
                                              // 더이상 availableGetPoint는 0이 아니다
                                              // 처음 접속한 사용자인 경우
                                              prefs.setInt('availableGetPoint',
                                                  2); // 다음에 받을 수 있는 건 2일차 포인트
                                              prefs.setString('lastPointYMD',
                                                  formattedDate); // 받은 날짜 저장
                                              prefs.setInt('lastPointDay', 1);
                                              setState(() {
                                                lastPointDay = 1;
                                                availableGetPoint = 2;
                                              });
                                              print('---');
                                              print(lastPointDay);
                                              print(availableGetPoint);
                                              print('---');
                                            }

                                            if (formattedDate !=
                                                    prefs.getString(
                                                        'lastPointYMD') &&
                                                tmp != lastPointDay &&
                                                availableGetPoint != 0) {
                                              // 지금 접속한 날짜와 마지막으로 포인트 받은 날짜가 동일하면 아무것도 일어나지 않는다
                                              // 다를 경우에만 변화가 생긴다
                                              // 포인트를 이미 받지 않은 상태여야 한다
                                              setState(() {
                                                // 포인트 받기
                                                if (lastPointDay + 1 != 8) {
                                                  // 내가 마지막으로 받은 게 6일차야 -> 7일차까지 업데이트가 되지
                                                  lastPointDay += 1;
                                                  print(tmp);
                                                  prefs.setInt(
                                                      'availableGetPoint',
                                                      tmp + 1);
                                                  prefs.setString(
                                                      'lastPointYMD',
                                                      formattedDate); // 시간 현재 시간으로 업데이트
                                                  prefs.setInt('lastPointDay',
                                                      lastPointDay);
                                                } else {
                                                  // 7일차가 되려고 하면
                                                }
                                              });
                                            }
                                            // Claim now를 누를 때 모든 포인트가 반영되도록
                                            // 들어온 시간 파악: Calendar누를 때

                                            //Claim now를 누르면,
                                            // 최근 변경일을 파악하고 , 변경일이 하루 이상이면 변경시간을 저장해주고 포인트를 올려준다 그리고 completed 이미지로 바꿔준다
                                            // 하루 이상 지나지 않으면 아무 반응이 없게 한다

                                            // 사용자가 포인트를 받았는지 안 받았는지를 알아야 한다
                                            // 그리고 변경일이 하루 이상 지났으면 업데이트해야하는 날짜에 테두리를 넣어줘야 한다

                                            // 받을 수 있는 포인트 day : availableGetPoint //
                                            // 마지막으로 받은 날짜: lastPointYMD // 2023년9월22일
                                            // 마지막으로 받은 포인트의 일수: lastPointDay --> 1일차, 2일차, 3일차... --> 마지막 기록이 1일차이면 2일차 포인트를 받게 해야한다
                                            // 현재 접속일: formattedDate
                                            // if( lastPointDate와 현재 접속 시간이 하루 이상 차이 && 아직 포인트를 받지 않은 상태) => 포인트를 받는다
                                            // 그렇지 않다면 동작하지 않게 한다
                                            // availableGetPoint 는 0, lastPointScore 0이면 처리
                                            // 2일차를 받을 수 있는 사용자 -> 마지막 받은 일차가 1일차 ? 업데이트
                                            // 2일차 받을 수 있고 이미 2일차 받음? 클릭 안됨

                                            // 처음에 0으로 세팅
                                            // 날짜와의 차이를 계산....
                                            // availableGetPoint 1 lastPointScore
                                          },
                                          child: const Text('CLAIM NOW'))
                                    ],
                                  ),
                                ),
                              )),
                        ]),
                      ),
                    ),
                ]
                    //   ),
                    ),
              );
            }
          },
        ));
  }

  Padding eachDayCoin(
      {required double top,
      required double left,
      required String imageAsset,
      required String text}) {
    return Padding(
      //100점
      padding: EdgeInsets.only(top: top, left: left),
      child: Container(
        width: SizeConfig.defaultSize! * 10,
        height: SizeConfig.defaultSize! * 10,
        decoration: const BoxDecoration(
            color: Color.fromARGB(255, 222, 220, 220),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.defaultSize! * 0.7,
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.defaultSize! * 1.7,
                  right: SizeConfig.defaultSize! * 1.7),
              child: Image.asset(
                imageAsset,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: SizeConfig.defaultSize! * 1.9,
                  fontFamily: 'Lilita'),
            )
          ],
        ),
      ),
    );
  }

  Drawer _Drawer(
      UserState userState, UserCubit userCubit, BuildContext context) {
    return Drawer(
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
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
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
                      padding:
                          EdgeInsets.only(left: SizeConfig.defaultSize! * 1),
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
                                fontSize: SizeConfig.defaultSize! * 1.4),
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
                                width: 23 * SizeConfig.defaultSize!,
                                height: 11 * SizeConfig.defaultSize!,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      child: Container(
                                        width: 23 * SizeConfig.defaultSize!,
                                        height: 11 * SizeConfig.defaultSize!,
                                        decoration: ShapeDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        left: 1.2 * SizeConfig.defaultSize!,
                                        top: 1.5 * SizeConfig.defaultSize!,
                                        // child: Transform.translate(
                                        //     offset: Offset(
                                        //         0.5,
                                        //         -0.7 *
                                        //             SizeConfig.defaultSize!),
                                        child: Image.asset(
                                          'lib/images/icons/${userState.voiceIcon}-c.png',
                                          height: SizeConfig.defaultSize! * 8,
                                        )),
                                    Positioned(
                                      left: 9.5 * SizeConfig.defaultSize!,
                                      top: 2.3 * SizeConfig.defaultSize!,
                                      child: SizedBox(
                                        width: 12.2 * SizeConfig.defaultSize!,
                                        height: 2 * SizeConfig.defaultSize!,
                                        child: Text(
                                          userState.voiceName!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize:
                                                2 * SizeConfig.defaultSize!,
                                            fontFamily: 'Molengo',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 10.2 * SizeConfig.defaultSize!,
                                      top: 6 * SizeConfig.defaultSize!,
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
                                              width:
                                                  11 * SizeConfig.defaultSize!,
                                              height:
                                                  3 * SizeConfig.defaultSize!,
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFFFA91A),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                'Edit this voice',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 1.4 *
                                                      SizeConfig.defaultSize!,
                                                  fontFamily: 'Molengo',
                                                  fontWeight: FontWeight.w400,
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
                                    builder: (context) => userState.purchase
                                        ? const RecInfo()
                                        : const Purchase(),
                                  ),
                                );
                              },
                              child: Container(
                                  width: 27 * SizeConfig.defaultSize!,
                                  height: 4 * SizeConfig.defaultSize!,
                                  decoration: ShapeDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: SizeConfig.defaultSize! * 2.5,
                                    color: const Color(0xFFFFA91A),
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
                                padding: EdgeInsets.all(
                                    0.5 * SizeConfig.defaultSize!),
                                child: Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 1.8 * SizeConfig.defaultSize!,
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
                                padding: EdgeInsets.all(
                                    0.2 * SizeConfig.defaultSize!),
                                child: Container(
                                    child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 1.8 * SizeConfig.defaultSize!,
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
                                      builder: (context) => Platform.isIOS
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
                                OneSignal.shared.removeExternalUserId();
                                _scaffoldKey.currentState?.closeDrawer();
                                setState(() {
                                  showSignOutConfirmation =
                                      !showSignOutConfirmation;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.all(
                                    0.5 * SizeConfig.defaultSize!),
                                padding: EdgeInsets.all(
                                    0.3 * SizeConfig.defaultSize!),
                                color: Colors
                                    .transparent, // 배경 터치 가능하게 하려면 배경 색상을 투명하게 설정
                                child: Text(
                                  'Do you want to Sign Out?',
                                  style: TextStyle(
                                    color: const Color(0xFF599FED),
                                    fontSize: 1.2 * SizeConfig.defaultSize!,
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
                                padding: EdgeInsets.all(
                                    0.5 * SizeConfig.defaultSize!),
                                child: Text(
                                  'Delete Account',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 1.8 * SizeConfig.defaultSize!,
                                    fontFamily: 'Molengo',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _scaffoldKey.currentState?.closeDrawer();
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
    ));
  }

  Column unlockedBook(HomeScreenBookModel book) {
    return Column(
      children: [
        Hero(
          tag: book.id,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            height: SizeConfig.defaultSize! * 22,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: book.thumbUrl,
              ),
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.defaultSize! * 1,
        ),
        SizedBox(
          width: SizeConfig.defaultSize! * 20,
          child: Text(
            book.title,
            style: TextStyle(
              fontFamily: 'GenBkBasR',
              fontSize: SizeConfig.defaultSize! * 2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Column lockedBook(HomeScreenBookModel book) {
    return Column(
      children: [
        Hero(
          tag: book.id,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            height: SizeConfig.defaultSize! * 22,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(children: [
                CachedNetworkImage(
                  imageUrl: book.thumbUrl,
                ),
                Container(
                  width: SizeConfig.defaultSize! * 22,
                  color:
                      const Color.fromARGB(255, 220, 220, 220).withOpacity(0.6),
                ),
                Align(
                  alignment: Alignment.topLeft,
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
          height: SizeConfig.defaultSize! * 1,
        ),
        SizedBox(
          width: SizeConfig.defaultSize! * 20,
          child: Text(
            book.title,
            style: TextStyle(
              fontFamily: 'GenBkBasR',
              fontSize: SizeConfig.defaultSize! * 2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
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
