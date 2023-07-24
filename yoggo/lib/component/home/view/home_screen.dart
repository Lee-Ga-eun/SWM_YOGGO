import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/login_screen.dart';
import 'package:yoggo/component/purchase.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/models/webtoon.dart';
import 'package:yoggo/component/book_intro.dart';
import 'package:yoggo/services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yoggo/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewModel/home_screen_cubit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<bookModel>> webtoons;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late String token;
  late bool purchase = true;
  late bool record = true;
  String userName = '';
  String userEmail = '';
  bool showEmail = false;
  bool showSignOutConfirmation = false;
  double dropdownHeight = 0.0;
  bool isDataFetched = false; // 데이터를 받아온 여부를 나타내는 플래그

  @override
  void initState() {
    super.initState();
    webtoons = ApiService.getTodaysToons();
    if (!isDataFetched) {
      getToken();
      getUserInfo();
    }
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      userInfo(token);
    });
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //purchase = prefs.getBool('purchase')!;
      //record = prefs.getBool('record')!;
      userName = prefs.getString('username')!;
    });
  }

  Future<String> userInfo(String token) async {
    var url = Uri.parse('https://yoggo-server.fly.dev/user/myInfo');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        final myJson = json.decode(response.body)[0];
        // purchase = myJson['purchase'];
        userName = myJson['name'];
        // record = myJson['record'];
      });
      isDataFetched = true;
      return response.body;
    } else {
      throw Exception('Failed to fetch data');
    }
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
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/bkground.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ' Welcome! ',
                    style: TextStyle(
                        fontSize: SizeConfig.defaultSize! * 1.8,
                        fontFamily: 'Molengo'),
                  ),
                  SizedBox(height: SizeConfig.defaultSize!),
                  Padding(
                    padding: EdgeInsets.only(left: SizeConfig.defaultSize! * 1),
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
                          userName,
                          style: TextStyle(
                              fontSize: SizeConfig.defaultSize! * 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ListTile(
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
                        height: 1 * SizeConfig.defaultSize!,
                      ),
                      GestureDetector(
                        child: Text('Sign out               ',
                            style: TextStyle(
                                fontSize: SizeConfig.defaultSize! * 1.6,
                                fontFamily: 'Molengo')),
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
                if (showSignOutConfirmation)
                  ListTile(
                    title: const Text(
                      'Wanna Sign out?',
                      style: TextStyle(color: Colors.blue),
                    ),
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
              record && purchase
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
                                        builder: (context) => purchase
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
                            record: record,
                            purchase: purchase,
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
    final dataCubit = BlocProvider.of<DataCubit>(context);

    return BlocBuilder<DataCubit, List<BookModel>>(
      builder: (context, state) {
        if (state.isEmpty) {
          return Center(
            child: Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.white,
                size: SizeConfig.defaultSize! * 16,
              ),
            ),
          );
        } else {
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
                        purchase: !purchase, // 임시로 지정 (전역으로 대체할 것임)
                        record: !record, //임시로 지정 (전역으로 대체할 것임)
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
