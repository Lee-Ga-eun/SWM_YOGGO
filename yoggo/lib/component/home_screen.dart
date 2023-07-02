import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/login_screen.dart';
import 'package:yoggo/component/purchase.dart';
import 'package:yoggo/models/webtoon.dart';
import 'package:yoggo/component/book_intro.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yoggo/size_config.dart';
import '../main.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<bookModel>> webtoons;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  void initState() {
    super.initState();
    webtoons = ApiService.getTodaysToons();
    print(contentUrl); // 책 목록 image에서 마지막 파라미터만 빠진 url
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.defaultSize!,
            ),
            Expanded(
              flex: 1,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fairy',
                        style: TextStyle(
                          fontFamily: 'BreeSerif',
                          fontSize: SizeConfig.defaultSize! * 4,
                        ),
                      ),
                      TextButton(
                        child: Text(
                          'Tale',
                          style: TextStyle(
                            fontFamily: 'BreeSerif',
                            fontSize: SizeConfig.defaultSize! * 4,
                          ),
                        ),
                        onPressed: () {
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
                  Positioned(
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.favorite),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Purchase(),
                          ),
                        );
                      },
                      //color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 5, child: bookList()),
          ],
        ),
      ),
    );
  }

  Container bookList() {
    return Container(
      child: FutureBuilder<List<bookModel>>(
          future: webtoons,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //Listview: 많은 양을 연속적으로 보여주고 싶을 때 row, column비추.
              return Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Expanded(
                    child: ListView.separated(
                      // ListView는 자동으로 스크롤뷰를 가져와줌
                      // ListView.builder는 메모리 낭비하지 않게 해줌(사용자가 스크롤 할 때 데이터 로딩)
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        // 사용자가 보고 있지 않다면 메모리에서 삭제
                        var book = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookIntro(
                                      title: book.title,
                                      thumb: contentUrl + book.thumb,
                                      id: book.id,
                                      summary: book.summary),
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
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: contentUrl + book.thumb,
                                      httpHeaders: const {
                                        "User-Agent":
                                            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 220,
                                child: Text(
                                  book.title,
                                  style:
                                      const TextStyle(fontFamily: 'BreeSerif'),
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
