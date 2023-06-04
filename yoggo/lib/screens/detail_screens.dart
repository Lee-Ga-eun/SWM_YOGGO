import 'package:flutter/material.dart';

class DetailScreens extends StatelessWidget {
  final String title, thumb, id;

  const DetailScreens({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1ECC9).withOpacity(1),
      // body: Column(
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Positioned(
      //           child: IconButton(
      //         onPressed: () {
      //           Navigator.of(context).pop();
      //         },
      //         icon: const Icon(Icons.close),
      //       )),
      //     ),
      //     Hero(
      //       tag: id,
      //       child: Center(
      //         child: Image.network(
      //           thumb,
      //           width: 200,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.topLeft,
              color: Colors.red,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Positioned(
                    child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
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
                    color: Colors.green,
                    child: Center(
                      child: Image.network(thumb),
                    ),
                  ),
                ),
                Expanded(
                  // 제목과 책 내용 요약
                  flex: 5,
                  child: Container(
                    color: Colors.orange,
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
                        const Text('줄거리'),
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
              color: Colors.blue,
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 50, bottom: 100),
                child: Positioned(
                    child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.play_circle,
                    size: 50,
                  ),
                )),
              ),
            ),
          ),
          //),
        ],
      ),
    );
  }
}
