import 'package:flutter/material.dart';
import 'package:yoggo/models/webtoon.dart';
import 'package:yoggo/screens/detail_screens.dart';
import 'package:yoggo/services/api_service.dart';
import 'package:yoggo/size_config.dart';
import './main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<bookModel>> webtoons;

  @override
  void initState() {
    super.initState();
    webtoons = ApiService.getTodaysToons();
    print(contentUrl); // 책 목록 image에서 마지막 파라미터만 빠진 url
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
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Fairy',
                      style: TextStyle(
                          fontFamily: 'BreeSerif',
                          fontSize: SizeConfig.defaultSize! * 4),
                    ),
                    // InkWell(
                    //   // 테스트를 위해서 아이콘을 누르면 슈퍼베이스에 있는 사진을 불러게 함
                    //   onTap: () {
                    //     // await downloadImage();
                    //     showDialog(
                    //       context: context,
                    //       builder: (context) => AlertDialog(
                    //         content: Image.memory(file!),
                    //       ),
                    //     );
                    //   },
                    //   child: Image.network(
                    //     'https://ulpaiggkhrfbfuvteqkq.supabase.co/storage/v1/object/sign/yoggo-storage/logo_v0.1.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJ5b2dnby1zdG9yYWdlL2xvZ29fdjAuMS5wbmciLCJpYXQiOjE2ODYwNjQ4MTksImV4cCI6MTE2ODYwNjQ4MTh9.6EEFRhZZVyEDVbBt326I7lZBY439Ufagj_ou43986ys&t=2023-06-06T15%3A20%3A20.023Z',
                    //   ),
                    // ),
                  
                    Text(
                      'Tale',
                      style: TextStyle(
                          fontFamily: 'BreeSerif',
                          fontSize: SizeConfig.defaultSize! * 4),
                    ),
                  ],
                ),
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
                                  builder: (context) => DetailScreens(
                                      title: book.title,
                                      thumb: book.thumb,
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
                                  child: Image.network(
                                    book.thumb,
                                    headers: const {
                                      "User-Agent":
                                          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                                    },
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
