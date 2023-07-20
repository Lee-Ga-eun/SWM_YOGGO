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
  String userName = '';
  String userEmail = '';
  bool showEmail = false;
  bool showSignOutConfirmation = false;
  double dropdownHeight = 0.0;
  late final bool purchase;
  late final bool record;
  bool isDataFetched = false; // 데이터를 받아온 여부를 나타내는 플래그

  @override
  void initState() {
    super.initState();
    webtoons = ApiService.getTodaysToons();
    if (!isDataFetched) {
      getToken();
    }
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      userInfo(token);
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
        purchase = myJson['purchase'];
        userName = myJson['name'];
        record = myJson['record'];
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
                  const Text(
                    ' Welcome! ',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: SizeConfig.defaultSize! * 1),
                  Text(
                    userName,
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
                      OutlinedButton(
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
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              width: 2,
                              color: Color.fromARGB(
                                  255, 234, 234, 234)), // 테두리 스타일 설정
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8), // 테두리의 모서리를 둥글게 설정
                          ),
                        ),
                        child: const Text('about subscribe'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        child: const Text('Sign out               '),
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
          minimum: const EdgeInsets.only(left: 30),
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
                          width: 35, // 이미지의 폭 설정
                          height: 35, // 이미지의 높이 설정
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(
              //   height: SizeConfig.defaultSize! * 1.5,
              // ),
              Expanded(
                flex: SizeConfig.defaultSize!.toInt() * 1,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.defaultSize! * 2,
                          right: SizeConfig.defaultSize! * 2),
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white),
                        // color: Colors.white,
                        height: SizeConfig.defaultSize! * 4,
                        child: const Center(
                          child: Text(
                            'Banner',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: SizeConfig.defaultSize!.toInt() * 4,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       left: SizeConfig.defaultSize! * 2,
                      //       right: SizeConfig.defaultSize! * 2),
                      //   child: Container(
                      //     decoration: const BoxDecoration(
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(10)),
                      //         color: Colors.white),
                      //     // color: Colors.white,
                      //     height: SizeConfig.defaultSize! * 4,
                      //     child: const Center(
                      //       child: Text(
                      //         'Banner',
                      //         style: TextStyle(fontSize: 24),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: SizeConfig.defaultSize! * 36,
                        child: bookList(),
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
              // Expanded(
              //   child: bookList(),
              // ),
            ],
          ),
        ),
      ),
      //   ),
    );
  }

  Container bookList() {
    return Container(
      child: FutureBuilder<List<bookModel>>(
          future: webtoons,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  // const SizedBox(
                  //   height: 40,
                  // ),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var book = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookIntro(
                                    title: book.title,
                                    thumb: book.thumb,
                                    id: book.id,
                                    summary: book.summary,
                                    purchase: purchase,
                                    record: record,
                                  ),
                                ));
                          },
                          child: Column(
                            children: [
                              Hero(
                                tag: book.id,
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  height: SizeConfig.defaultSize! * 22,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: book.thumb,
                                      httpHeaders: const {
                                        "User-Agent":
                                            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                                      },
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
                                      fontSize: SizeConfig.defaultSize! * 1.6),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 20),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.orange,
                ),
              );
            }
          }),
    );
  }
}
