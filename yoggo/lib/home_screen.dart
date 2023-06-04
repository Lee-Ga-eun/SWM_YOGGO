import 'package:flutter/material.dart';
import 'package:yoggo/models/webtoon.dart';
import 'package:yoggo/screens/detail_screens.dart';
import 'package:yoggo/services/api_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  Future<List<WebtoonModel>> webtoons = ApiService.getTodaysToons();

  void pointFunction() {} // AppBar 아이콘클릭

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 컬러
      appBar: AppBar(
        // actions: 오른쪽 사이드바, leading: 왼쪽 사이드바
        elevation: 0, // 음영 제거
        backgroundColor: const Color(0xFFE2DDEB), // App Bar 컬러지정
        title: const Text(
          "YOGGO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.money_rounded),
            onPressed: pointFunction,
            iconSize: 40,
            color: Colors.white,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: pointFunction,
              icon: const Icon(
                Icons.home,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder(
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
                        var webtoon = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreens(
                                      title: webtoon.title,
                                      thumb: webtoon.thumb,
                                      id: webtoon.id),
                                ));
                          },
                          child: Column(
                            children: [
                              Hero(
                                tag: webtoon.id,
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  height: 200,
                                  child: Image.network(
                                    webtoon.thumb,
                                    headers: const {
                                      "User-Agent":
                                          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                                    },
                                  ),
                                ),
                              ),
                              Text(webtoon.title),
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
