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
  //String voices='';
  List<dynamic> voices = [];
  int cvi = 0;

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
        //print(contentText);
        voices = data['voice'];
        print(voices);
        for (var voice in voices) {
          print(voice['voiceName']);
        }
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

  String _getImageForVoice(String voiceName) {
    switch (voiceName) {
      case 'Kelly':
      return 'https://media.discordapp.net/attachments/1114865651312508958/1115512272987623484/actor_kelly.png?width=75&height=110';
      case 'Ethan':
      return 'https://media.discordapp.net/attachments/1114865651312508958/1115512273297997884/actor_ethan.png?width=112&height=110';
      case 'Liam':
      return 'https://media.discordapp.net/attachments/1114865651312508958/1115512273604186202/actor_liam.png?width=119&height=108';
      default:
      return '';
    }
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
        child:Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          top: 10.0,
        ),
          child:Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.topLeft,
                //color: Colors.red,

                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 1.0,
                  ),
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
                      child: ListView(children: [
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
                        // --------------------피그마 아이콘이랑 일치하는 것:: contentVoiceId 동적 기능 없음 ------------
                        /*GestureDetector(
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
                        ),*/
                        // ----------------성우 리스트 수에 따라 아이콘 생성 시작-------------------
                        Row(
                          children: voices.map((voice) {
                            bool isClicked = (cvi == voice['contentVoiceId']);
                            //for (var voice in voices)
                            return GestureDetector(
                              onTap: () {
                                cvi = voice['contentVoiceId']; // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                setState(() {
                                  isClicked = !isClicked; // 클릭 상태
                                });
                              },
                              child: Column(
                                children: [
                                    Image.network(
                                    _getImageForVoice(voice['voiceName']),
                                    //Icons.person, // Icons.person은 기본 제공되는 아이콘이다. 이걸 그림으로 바꾸려면 Icon()을 지우고
                                    //Image.network('https://media.discordapp.net/attachments/1114865651312508958/1115512272987623484/actor_kelly.png',) 이렇게 처리를 해줘야 한다
                                    color: isClicked
                                        ? const Color.fromARGB( // 선택하면 색이 바껴야 하는데 전부 다 바껴서 문제
                                            255, 255, 66, 129)
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(voice['voiceName']),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                        // --------------------성우 아이콘 배치 완료  ---------
                      ]),
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
                        builder: (context) => FairytalePage( // 다음 화면으로 contetnVoiceId를 가지고 이동
                          voiceId: cvi,
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
      ),
    );
  }
}
