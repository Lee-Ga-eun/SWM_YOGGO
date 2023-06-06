import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

//import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';

class FairytalePage extends StatefulWidget {
  final int voiceId;
  const FairytalePage({super.key, required this.voiceId});

  @override
  _FairytalePageState createState() => _FairytalePageState();
}

class _FairytalePageState extends State<FairytalePage> {
  int currentPage = 1;
  String text = '';
  String bookImage = '';
  int? position;
  int? last;
  // current page 와 last page의 숫자가 같으면 체크표시로 아이콘 변경
  // 체크표시로 변경되면 home screen으로 넘어감

  AudioPlayer audioPlayer = AudioPlayer();
  String audioUrl = '';

  Future<void> fetchPageData() async {
    final url =
        'https://yoggo-server.fly.dev/content/page?contentVoiceId=${widget.voiceId}&order=$currentPage';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      //List<dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print(responseData);
      //Map<String, dynamic> data = responseData[0];

      final contentText = responseData['text'];
      print("position의 값");
      print(responseData['position']);
      audioUrl = responseData['audioUrl'];
      last = responseData['last'];
      bookImage = responseData['imageUrl'];
      position = responseData['position'];

      setState(() {
        text = contentText;
        audioUrl = audioUrl;
        playAudio();
      });
    } else {}
  }

  @override
  void initState() {
    super.initState();
    fetchPageData();
    // playAudio();
  }

  void nextPage() {
    setState(() {
      // audioPlayer.stop();
      stopAudio();
      currentPage++;
      fetchPageData();
    });
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        //  dispose();
        //  audioPlayer.stop();
        stopAudio();
        currentPage--;
        fetchPageData();
      });
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }

  void playAudio() async {
    stopAudio();
    //final player = AudioPlayer();
    //print(audioUrl);
    int result = await audioPlayer.play(audioUrl);
    if (result == 1) {
      // success
      print('Audio played successfully');
    } else {
      // error
      print('Error playing audio');
    }
  }

  void stopAudio() async {
    await audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  //color: Colors.orange,
                  alignment: Alignment.topLeft,
                  //color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 1.0,
                    ),
                    child: Positioned(
                        child: IconButton(
                      onPressed: () {
                        stopAudio();
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
                flex: 6,
                // 본문 글자
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: position == 1 ? Colors.red : Colors.white,
                        child: position == 1
                            ? Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(50), // 모서리를 원형으로 설정
                                  child: Image.network(
                                    bookImage,
                                    fit: BoxFit.cover,
                                    // 이미지를 컨테이너에 맞게 조정
                                  ),
                                ),
                              ) // // 그림을 1번 화면에 배치
                            : Padding(
                                padding:
                                    const EdgeInsets.only(left: 50, right: 10),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: 'BreeSerif'),
                                ),
                              ), // 글자를 2번 화면에 배치
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: position == 2 ? Colors.red : Colors.white,
                        child: position == 2
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(50), // 모서리를 원형으로 설정
                                child: Image.network(
                                  bookImage,
                                  fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
                                ),
                              ) // 그림을 2번 화면에 배치
                            : Padding(
                                padding:
                                    const EdgeInsets.only(right: 50, left: 20),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                      fontSize: 20, fontFamily: 'BreeSerif'),
                                ),
                              ), // 글자를 1번 화면에 배치
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  // color: Colors.blue,
                  child: Row(
                    // 화살표
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: previousPage,
                      ),
                      const SizedBox(width: 16),
                      currentPage != last
                          ? IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: nextPage,
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 40,
                              ),
                              onPressed: () =>
                                  {stopAudio(), Navigator.of(context).pop()},
                            )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
