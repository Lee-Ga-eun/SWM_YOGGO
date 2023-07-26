import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/login_screen.dart';
import 'package:yoggo/component/purchase.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/component/book_intro.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yoggo/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../check_voice.dart';
import '../viewModel/home_screen_cubit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../globalCubit/user/user_cubit.dart';
import '../../push.dart';
import 'package:yoggo/main.dart';

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
  late bool purchase = true;
  late bool record = true;
  String userName = '';
  String userEmail = '';
  late String voiceIcon = "😃";
  late String voiceName = "User";
  bool showEmail = false;
  bool showSignOutConfirmation = false;
  double dropdownHeight = 0.0;
  bool isDataFetched = false; // 데이터를 받아온 여부를 나타내는 플래그

  @override
  void initState() {
    super.initState();
    //webtoons = ApiService.getTodaysToons();
    // if (!isDataFetched) {
    //getToken();
    //getUserInfo();
    //}
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      //userInfo(token);
      //getVoiceInfo(token);
    });
  }

  // Future<void> getUserInfo() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     //purchase = prefs.getBool('purchase')!;
  //     //record = prefs.getBool('record')!;
  //     userName = prefs.getString('username')!;
  //   });
  // }

  // Future<String> getVoiceInfo(String token) async {
  //   var url = Uri.parse('https://yoggo-server.fly.dev/user/myVoice');
  //   var response = await http.get(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     final myJson = json.decode(response.body);
  //     if (myJson != []) {
  //       setState(() {
  //         //inferenceUrl = myJson[0]['inferenceUrl'];
  //         voiceName = myJson[0]['name'];
  //         voiceIcon = myJson[0]['icon'];
  //       });
  //     }
  //     return response.body;
  //   } else {
  //     throw Exception('Failed to fetch data');
  //   }
  // }

  // Future<String> userInfo(String token) async {
  //   var url = Uri.parse('https://yoggo-server.fly.dev/user/myInfo');
  //   var response = await http.get(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       final myJson = json.decode(response.body)[0];
  //       // purchase = myJson['purchase'];
  //       userName = myJson['name'];
  //       // record = myJson['record'];
  //     });
  //     isDataFetched = true;
  //     return response.body;
  //   } else {
  //     throw Exception('Failed to fetch data');
  //   }
  // }

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
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
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
                  minimum: EdgeInsets.only(left: 3 * SizeConfig.defaultSize!),
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
                  minimum: EdgeInsets.only(left: 3 * SizeConfig.defaultSize!),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // OutlinedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => purchase
                        //             ? const RecordInfo()
                        //             : const Purchase(),
                        //       ),
                        //     );
                        //   },
                        //   style: OutlinedButton.styleFrom(
                        //     side: const BorderSide(
                        //         width: 2,
                        //         color: Color.fromARGB(
                        //             255, 234, 234, 234)), // 테두리 스타일 설정
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius:
                        //           BorderRadius.circular(8), // 테두리의 모서리를 둥글게 설정
                        //     ),
                        //   ),
                        //   child: const Text('about subscribe'),
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
                                  //이벤트 넣어보기
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
                                            color:
                                                Colors.white.withOpacity(0.5),
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
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CheckVoice(
                                                    infenrencedVoice: '48',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                                width: 11 *
                                                    SizeConfig.defaultSize!,
                                                height:
                                                    3 * SizeConfig.defaultSize!,
                                                decoration: ShapeDecoration(
                                                  color:
                                                      const Color(0xFFFFA91A),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => userState.purchase
                                          ? const RecordInfo()
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
                        GestureDetector(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 1.8 * SizeConfig.defaultSize!,
                              fontFamily: 'Molengo',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              showSignOutConfirmation =
                                  !showSignOutConfirmation; // dropdown 상태 토글
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (showSignOutConfirmation)
                  GestureDetector(
                    child: Transform.translate(
                        offset: Offset(-2 * SizeConfig.defaultSize!,
                            0.5 * SizeConfig.defaultSize!),
                        child: Text(
                          'Do you want to Sign Out?',
                          style: TextStyle(
                            color: const Color(0xFF599FED),
                            fontSize: 1.2 * SizeConfig.defaultSize!,
                            fontFamily: 'Molengo',
                            fontWeight: FontWeight.w400,
                          ),
                        )),
                    //),
                    onTap: () {
                      logout();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      )),
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
                          showNotification(flutterLocalNotificationsPlugin);

                          _scaffoldKey.currentState?.openDrawer();
                        },
                        child: Image.asset(
                          'lib/images/hamburger.png',
                          width: 3.5 * SizeConfig.defaultSize!, // 이미지의 폭 설정
                          height: 3.5 * SizeConfig.defaultSize!, // 이미지의 높이 설정
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
                                left: SizeConfig.defaultSize! * 2,
                                right: SizeConfig.defaultSize! * 2),
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Color.fromARGB(255, 255, 201, 29),
                                //   border: Border.all(
                                //   color: const Color.fromARGB(255, 255, 169, 26)),
                              ),
                              // color: Colors.white,
                              height: SizeConfig.defaultSize! * 4,
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => userState.purchase
                                            ? const RecordInfo()
                                            : const Purchase(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Want to read a book in your voice?',
                                    style: TextStyle(
                                        fontSize: 2 * SizeConfig.defaultSize!,
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
                          create: (context) =>
                              DataCubit()..loadData(), // DataCubit 생성 및 데이터 로드
                          child: DataList(
                            record: userState.record,
                            purchase: userState.purchase,
                          ),
                        ),
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
}

class DataList extends StatelessWidget {
  final bool record;
  final bool purchase;
  const DataList({Key? key, required this.record, required this.purchase})
      : super(key: key);
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static Future<void> _sendBookClickEvent(contentId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_click',
        parameters: <String, dynamic>{'contentId': contentId},
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 큐빗을 가져오기.
    //final dataCubit = BlocProvider.of<DataCubit>(context);

    return BlocBuilder<DataCubit, List<BookModel>>(
      builder: (context, state) {
        if (state.isEmpty) {
          showNotification(flutterLocalNotificationsPlugin);

          return Center(
            child: Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: const Color.fromARGB(255, 255, 169, 26),
                size: SizeConfig.defaultSize! * 10,
              ),
            ),
          );
        } else {
          showNotification(flutterLocalNotificationsPlugin);
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.length,
            itemBuilder: (context, index) {
              final book = state[index];
              return InkWell(
                onTap: () {
                  _sendBookClickEvent(book.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookIntro(
                        title: book.title,
                        thumb: book.thumbUrl,
                        id: book.id,
                        summary: book.summary,
                        purchase: purchase, // 임시로 지정 (전역으로 대체할 것임)
                        record: record, //임시로 지정 (전역으로 대체할 것임)
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: SizeConfig.defaultSize! * 22,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: book.thumbUrl,
                            // httpHeaders: const {
                            //   "User-Agent":
                            //       "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                            // },
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
                          fontFamily: 'BreeSerif',
                          fontSize: SizeConfig.defaultSize! * 1.6,
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
                SizedBox(width: 2 * SizeConfig.defaultSize!),
          );
        }
      },
    );
  }
}
