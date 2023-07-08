import 'package:flutter/material.dart';
import '../component/reader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yoggo/size_config.dart';

class BookIntro extends StatefulWidget {
  final String title, thumb, summary;
  final int id;

  const BookIntro({
    // super.key,
    Key? key,
    required this.title,
    required this.thumb,
    required this.id,
    required this.summary,
  }) : super(key: key);

  @override
  _BookIntroState createState() => _BookIntroState();
}

class _BookIntroState extends State<BookIntro> {
  bool isSelected = true;
  bool isClicked = false;
  String text = '';
  int voiceId = 10;
  //String voices='';
  List<dynamic> voices = [];
  int cvi = 0;
  bool canChanged = true;
  int lastPage = 0;
  int contentId = 1;

  Future<void> fetchPageData() async {
    final url = 'https://yoggo-server.fly.dev/content/${widget.id}';
    final response = await http.get(Uri.parse(url));
    if (mounted) {
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        // print(responseData);
        Map<String, dynamic> data = responseData[0];
        voices = data['voice'];
        for (var voice in voices) {
          if (voice['voiceId'] == 1) {
            cvi = voice['contentVoiceId'];
          }
        }
        final contentText = data['voice'][0]['voiceName'];
        lastPage = data['last'];
        contentId = data['contentId'];
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
    // precacheImages(context);
    SizeConfig().init(context);
    if (cvi == 0) {
      return Scaffold(
        //backgroundColor: Colors.yellow, // 노란색 배경 설정
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/bkground.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                  strokeWidth: 5, // 동그라미 로딩의 크기 조정
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text('Loading a book'),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF1ECC9).withOpacity(1),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.defaultSize!,
            top: SizeConfig.defaultSize!,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: SizeConfig.defaultSize! * 4,
                      ),
                    )),
              ),
              //),

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
                                      color: Colors.grey
                                          .withOpacity(0.5), // 그림자 색상
                                      spreadRadius: 5, // 그림자의 확산 범위
                                      blurRadius: 7, // 그림자의 흐림 정도
                                      offset: const Offset(
                                          0, 3), // 그림자의 위치 (가로, 세로)
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
                          SizedBox(
                            height: SizeConfig.defaultSize! * 2,
                          ),
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontSize: SizeConfig.defaultSize! * 3.5,
                                fontFamily: 'BreeSerif'),
                          ),
                          SizedBox(
                            height: SizeConfig.defaultSize! * 0.3,
                          ),
                          Row(
                            //  mainAxisAlignment: MainAxisAlignment.center,
                            children: voices.map((voice) {
                              bool isClicked = (cvi == voice['contentVoiceId']);
                              String voiceName = voice['voiceName'];
                              String imageName =
                                  'lib/images/$voiceName.png'; // 동적으로 파일 경로 설정
                              return GestureDetector(
                                onTap: () {
                                  cvi = voice[
                                      'contentVoiceId']; // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                  setState(() {
                                    isClicked = !isClicked;
                                    canChanged = true; // 클릭 상태
                                  });
                                },
                                child: Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Image.asset(
                                        imageName,
                                        color: isClicked
                                            ? null
                                            : const Color.fromARGB(
                                                // 선택하면 색이 바껴야 하는데 전부 다 바껴서 문제
                                                255,
                                                255,
                                                66,
                                                129),
                                        height: SizeConfig.defaultSize! * 6.5,
                                      ),
                                    ),
                                    SizedBox(
                                        height: SizeConfig.defaultSize! * 0.3),
                                    Text(voice['voiceName']),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: SizeConfig.defaultSize! * 0.1,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                right: SizeConfig.defaultSize! * 4),
                            child: Text(
                              widget.summary,
                              style: TextStyle(
                                  fontFamily: 'Prata',
                                  fontSize: SizeConfig.defaultSize! * 2),
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.defaultSize!,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(children: [
                  Expanded(
                    // 썸네일 사진
                    flex: 1,
                    child: Container(
                        //color: Colors.white,
                        ),
                  ),
                  Expanded(
                      // 썸네일 사진
                      flex: 1,
                      child: Container()),
                  Expanded(
                    // 제목과 책 내용 요약
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        canChanged
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FairytalePage(
                                    // 다음 화면으로 contetnVoiceId를 가지고 이동
                                    voiceId: cvi,
                                    lastPage: lastPage,
                                    isSelected: true,
                                  ),
                                ),
                              )
                            : null;
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        //alignment: Alignment.topRight,
                        children: [
                          Text(
                            'Selected?',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.defaultSize! * 2),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                right: SizeConfig.defaultSize! * 2),
                            child: Icon(
                              Icons.arrow_circle_right_outlined,
                              size: SizeConfig.defaultSize! * 5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ), // --------------------성우 아이콘 배치 완료  ---------
                ]),
              ),
//추가

              //  ),
            ],
          ),
        ),
      ),
    );
  }
}
