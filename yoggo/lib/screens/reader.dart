import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../main.dart';
import 'package:yoggo/size_config.dart';
import 'package:audioplayers/audioplayers.dart';

class FairytalePage extends StatefulWidget {
  final int voiceId; //detail_screen에서 받아오는 것들
  final bool isSelected;
  final int lastPage;
  const FairytalePage({
    super.key,
    required this.voiceId, // detail_screen에서 받아오는 것들 초기화
    required this.isSelected,
    required this.lastPage,
  });

  @override
  _FairyTalePageState createState() => _FairyTalePageState();
}

class _FairyTalePageState extends State<FairytalePage> {
  // List<BookPage> pages = []; // 책 페이지 데이터 리스트
  List<Map<String, dynamic>> pages = [];

  int currentPageIndex = 0; // 현재 페이지 인덱스
  bool isPlaying = true;

  AudioPlayer audioPlayer = AudioPlayer();
  Source audioUrl = UrlSource('');

  @override
  void initState() {
    super.initState();
    // 책 페이지 데이터 미리 불러오기
    fetchAllBookPages();
  }

  Future<void> fetchAllBookPages() async {
    // API에서 모든 책 페이지 데이터를 불러와 pages 리스트에 저장
    final response = await http.get(Uri.parse(
        'https://yoggo-server.fly.dev/content/page?contentVoiceId=${widget.voiceId}'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is List<dynamic>) {
        setState(() {
          pages = List<Map<String, dynamic>>.from(jsonData);
          // print(pages);
        });
      }
    } else {
      // 에러 처리
    }
  }

  void nextPage() {
    setState(() {
      isPlaying = false;
      stopAudio();
      if (currentPageIndex < widget.lastPage) {
        currentPageIndex++;
        if (currentPageIndex == widget.lastPage) {
          currentPageIndex -= 1;
        }
      }
    });
  }

  void previousPage() {
    setState(() {
      if (currentPageIndex > 0) {
        currentPageIndex--;
        isPlaying = false;
        stopAudio();
      }
    });
  }

  void playAudio() async {
    stopAudio();
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.stopped) {
        setState(() {
          isPlaying = false;
        });
      }
    });
    await audioPlayer.play(audioUrl);
    setState(() {
      isPlaying = true;
    });
  }

  void stopAudio() async {
    await audioPlayer.stop();
  }

  void pauseAudio() async {
    await audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  void resumeAudio() async {
    await audioPlayer.resume();
    setState(() {
      isPlaying = true;
    });
  }

  @override
  void dispose() {
    // audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(currentPageIndex);
    print(widget.lastPage);
    if (pages.isEmpty) {
      // 데이터가 아직 불러와지지 않았을 경우 로딩 화면 등을 표시
      return const CircularProgressIndicator();
    }
    return Scaffold(
      body: Stack(
        children: [
          // 현재 페이지 위젯
          Visibility(
            visible: true,
            child: PageWidget(
              page: currentPageIndex < widget.lastPage
                  ? pages[currentPageIndex]
                  : pages[widget.lastPage - 1],
              audioUrl: supabaseAudioUrl + pages[currentPageIndex]['audioUrl'],
              isPlaying: isPlaying,
              playAudio: playAudio,
              stopAudio: stopAudio,
              pauseAudio: pauseAudio,
              resumeAudio: resumeAudio,
            ),
          ),
          // 다음 페이지 위젯
          Visibility(
            visible: false,
            child: //PageWidget(page: pages[currentPageIndex + 1]),
                PageWidget(
              page: currentPageIndex < widget.lastPage
                  ? currentPageIndex == widget.lastPage - 1
                      ? pages[currentPageIndex]
                      : pages[currentPageIndex + 1]
                  : pages[widget.lastPage - 1],
              audioUrl: supabaseAudioUrl + pages[currentPageIndex]['audioUrl'],
              isPlaying: isPlaying,
              playAudio: playAudio,
              stopAudio: stopAudio,
              pauseAudio: pauseAudio,
              resumeAudio: resumeAudio,
            ),
          ),
          // 이전 페이지 위젯
          Visibility(
            visible: false,
            child: PageWidget(
              page: currentPageIndex != 0
                  ? pages[currentPageIndex - 1]
                  : pages[0],
              audioUrl: supabaseAudioUrl + pages[currentPageIndex]['audioUrl'],
              isPlaying: isPlaying,
              playAudio: playAudio,
              stopAudio: stopAudio,
              pauseAudio: pauseAudio,
              resumeAudio: resumeAudio,
            ),
            // page: currentPageIndex > 0
            //     ? pages[currentPageIndex - 1]
            //     : pages[0]),
          ),
          // 오른쪽 화살표 버튼
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: nextPage,
            ),
          ),
          // 왼쪽 화살표 버튼
          Positioned(
            bottom: 0,
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: previousPage,
            ),
          ),
        ],
      ),
    );
  }
}

class PageWidget extends StatefulWidget {
  final Map<String, dynamic> page;
  final String audioUrl;
  final bool isPlaying;
  final VoidCallback playAudio;
  final VoidCallback stopAudio;
  final VoidCallback pauseAudio;
  final VoidCallback resumeAudio;
  // const PageWidget({Key? key, required this.page}) : super(key: key);

  const PageWidget({
    Key? key,
    required this.page,
    required this.audioUrl,
    required this.isPlaying,
    required this.playAudio,
    required this.stopAudio,
    required this.pauseAudio,
    required this.resumeAudio,
  }) : super(key: key);

  @override
  _PageWidgetState createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  @override
  Widget build(BuildContext context) {
    //   final pageNum = widget.page['pageNum'] as int;
    final text = widget.page['text'] as String;
    final imageUrl = contentUrl + widget.page['imageUrl'];
    final imagePostion = widget.page['position'];
    print(widget.page);
    print(widget.audioUrl);
    print(widget.isPlaying);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.defaultSize!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Expanded(
              //   flex: 1,
              //   child:
              Container(
                  color: Colors.orange,
                  alignment: Alignment.topLeft,
                  //color: Colors.red,

                  //child: Positioned(
                  //  left: 1.0,
                  child: IconButton(
                    onPressed: () {
                      // stopAudio();
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: SizeConfig.defaultSize! * 4,
                    ),
                  )),
              // ),
              //),

              Expanded(
                flex: 6,
                // 본문 글자
                child: Row(
                  children: [
                    Expanded(
                      flex: imagePostion == 1 ? 1 : 2,
                      child: Container(
                        //color: position == 1 ? Colors.red : Colors.white,
                        child: imagePostion == 1
                            ? Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.defaultSize! * 2),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(20), // 모서리를 원형으로 설정
                                  child: Image.network(
                                    imageUrl,
                                    //fit: BoxFit.cover,
                                    // 이미지를 컨테이너에 맞게 조정
                                  ),
                                ),
                              ) // // 그림을 1번 화면에 배치
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: SizeConfig.defaultSize! * 5,
                                    right: SizeConfig.defaultSize!),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        // textAlign: TextAlign.center,
                                        text,
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.defaultSize! * 2,
                                            fontFamily: 'BreeSerif'),
                                      ),
                                    ],
                                  ),
                                ),
                              ), // 글자를 2번 화면에 배치
                      ),
                    ),
                    Expanded(
                      flex: imagePostion == 0 ? 1 : 2,
                      child: Container(
                        //color: position == 2 ? Colors.red : Colors.white,
                        child: imagePostion == 0
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(20), // 모서리를 원형으로 설정
                                child: Image.network(
                                  imageUrl,
                                  // fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
                                ),
                              ) // 그림을 2번 화면에 배치
                            : Padding(
                                padding: EdgeInsets.only(
                                    right: SizeConfig.defaultSize! * 2,
                                    left: SizeConfig.defaultSize! * 2),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        // textAlign: TextAlign.center,
                                        text,
                                        style: TextStyle(
                                            fontSize:
                                                SizeConfig.defaultSize! * 2,
                                            fontFamily: 'BreeSerif'),
                                      ),
                                    ],
                                  ),
                                ),
                              ), // 글자를 1번 화면에 배치
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
