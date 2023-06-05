import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../screens/reader.dart';

class DetailScreens extends StatelessWidget {
  final String title, thumb, summary;
  final int id;

  const DetailScreens({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1ECC9).withOpacity(1),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topLeft,
                //color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Positioned(
                      child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 40,
                    ),
                  )),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Row(
                children: [
                  Expanded(
                    // 썸네일 사진
                    flex: 5,
                    child: Container(
                      // color: Colors.green,
                      child: Hero(
                        tag: id,
                        child: Center(
                          child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.grey.withOpacity(0.5), // 그림자 색상
                                    spreadRadius: 5, // 그림자의 확산 범위
                                    blurRadius: 7, // 그림자의 흐림 정도
                                    offset:
                                        const Offset(0, 3), // 그림자의 위치 (가로, 세로)
                                  ),
                                ],
                              ),
                              child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(thumb))),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    // 제목과 책 내용 요약
                    flex: 5,
                    child: Container(
                      //   color: Colors.orange,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 70,
                          ),
                          Text(
                            title,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Text(summary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 2,
                child: Container(
                  //   color: Colors.blue,
                  // margin: const EdgeInsets.only(right: 50, bottom: 100),

                  alignment: Alignment.topRight,
                  // child: Padding(
                  // padding: const EdgeInsets.only(right: 50, bottom: 100),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FairytalePage(),
                          ));
                    },
                    child: const Icon(
                      Icons.arrow_circle_right_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                )),
            // ),
            //),
            //),
            //),
          ],
        ),
      ),
    );
  }
}
