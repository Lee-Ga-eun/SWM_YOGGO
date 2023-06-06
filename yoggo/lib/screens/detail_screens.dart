import 'package:flutter/material.dart';
import '../screens/reader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailScreens extends StatefulWidget {
  final String title, thumb, summary;
  final int id;

  const DetailScreens({
    // super.key,
    Key? key,
    required this.title,
    required this.thumb,
    required this.id,
    required this.summary,
  }) : super(key: key);

  @override
  _DetailScreensState createState() => _DetailScreensState();
}

class _DetailScreensState extends State<DetailScreens> {
  bool isClicked = false;
  String text = '';
  int voiceId = 10;

  Future<void> fetchPageData() async {
    final url = 'https://yoggo-server.fly.dev/content/${widget.id}';
    final response = await http.get(Uri.parse(url));
    if (mounted) {
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        Map<String, dynamic> data = responseData[0];

        final contentText = data['voice'][0]['voiceName'];
        print('voiceName');
        print(contentText);

        setState(() {
          text = contentText;
          voiceId = data['voice'][0]['contentVoiceId'];
        });
      } else {}
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPageData();
  }

  @override
  Widget build(BuildContext context) {
    print('vociceId');
    print(voiceId);
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
                        tag: widget.id,
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
                                  child: Image.network(widget.thumb))),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    // 제목과 책 내용 요약
                    flex: 5,
                    child: Container(
                      //   color: Colors.orange,
                      child: ListView(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.title,
                            style: const TextStyle(
                                fontSize: 40, fontFamily: 'BreeSerif'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Text(
                              widget.summary,
                              style: const TextStyle(
                                  fontFamily: 'Prata', fontSize: 20),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isClicked = !isClicked; // 클릭 상태를 토글합니다.
                              });
                            },
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Image.network(
                                  'https://media.discordapp.net/attachments/1114865651312508958/1115512272987623484/actor_kelly.png',
                                  width: 30,
                                  color: isClicked
                                      ? const Color.fromARGB(255, 255, 66, 129)
                                      : null,
                                ),
                              ),
                            ),
                          )
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
                //child: Padding(
                //padding: const EdgeInsets.only(right: 30, bottom: 100),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FairytalePage(
                          voiceId: voiceId,
                        ),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.arrow_circle_right_outlined,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            //  ),
          ],
        ),
      ),
    );
  }
}
