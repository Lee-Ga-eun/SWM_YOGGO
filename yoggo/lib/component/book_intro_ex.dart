import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoggo/component/purchase.dart';
import 'package:yoggo/component/record_info.dart';
import '../component/reader.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yoggo/size_config.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BookIntro extends StatefulWidget {
  final String title, thumb, summary;
  final int id;
  bool? record;
  bool? purchase;

  BookIntro({
    // super.key,
    Key? key,
    required this.title,
    required this.thumb,
    required this.id,
    required this.summary,
    this.purchase,
    this.record,
  }) : super(key: key);

  @override
  _BookIntroState createState() => _BookIntroState();
}

class _BookIntroState extends State<BookIntro> {
  bool isSelected = true;
  bool isClicked0 = true;
  bool isClicked1 = false;
  bool isClicked2 = false;
  bool isPurchased = false;
  bool wantPurchase = false;
  bool goRecord = false;
  bool completeInference = true;
  late int inferenceId = 1000;
  late String token;
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
    getToken();
  }

  Future<void> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token')!;
      purchaseInfo(token);
    });
  }

//구매한 사람인지, 이 책이 인퍼런스되어 있는지 확인
  Future<String> purchaseInfo(String token) async {
    var url = Uri.parse(
        'https://yoggo-server.fly.dev/user/purchaseInfo/${widget.id}');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        isPurchased = json.decode(response.body)['purchase'];
        inferenceId = json.decode(response.body)['inference'];
      });
      return response.body;
    } else {
      throw Exception('Failed to fetch data');
    }
  }

//인퍼런스 안 되어 있다면 시작하도록
  Future<void> startInference(String token) async {
    var url = Uri.parse('https://yoggo-server.fly.dev/producer/book');
    Map data = {'contentId': widget.id};
    var response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data));
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          inferenceId = json.decode(response.body)['id'];
        });
      }
    } else {
      throw Exception('Failed to start inference');
    }
  }

//인퍼런스 완료 되었는지 (ContentVoice) 확인
  Future<bool> checkInference(String token) async {
    var url = Uri.parse(
        'https://yoggo-server.fly.dev/content/inference/${widget.id}');
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        completeInference = true;
      });
      return true;
    } else {
      return false;
    }
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
          child: Center(
            // 로딩 화면
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Color.fromARGB(255, 255, 169, 26),
              size: SizeConfig.defaultSize! * 10,
            ),
          ),
        ),
      );
    }
    return Scaffold(
        backgroundColor: const Color(0xFFF1ECC9).withOpacity(1),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/bkground.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                // left: 0.5 * SizeConfig.defaultSize!,
                top: SizeConfig.defaultSize!,
              ),
              child: SafeArea(
                bottom: false,
                top: false,
                child: Column(children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            // [X]
                            // Icons.highlight_off,
                            Icons.clear,
                            color: Colors.black,
                            size: 3.5 * SizeConfig.defaultSize!,
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
                          flex: 4,
                          child: Container(
                            // color: Colors.green,
                            child: Hero(
                              tag: widget.id,
                              child: Center(
                                child: Container(
                                    // margin: EdgeInsets.only(top: SizeConfig.defaultSize! * 4),
                                    // decoration: BoxDecoration(
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.grey
                                    //         .withOpacity(0.5), // 그림자 색상
                                    //     spreadRadius: 5, // 그림자의 확산 범위
                                    //     blurRadius: 7, // 그림자의 흐림 정도
                                    //     offset: const Offset(
                                    //         0, 3), // 그림자의 위치 (가로, 세로)
                                    //   ),
                                    // ],
                                    // ),
                                    child: Column(children: [
                                  SizedBox(
                                    height: SizeConfig.defaultSize! * 2,
                                  ),
                                  Container(
                                      width: SizeConfig.defaultSize! * 30,
                                      height: SizeConfig.defaultSize! * 30,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Image.network(widget.thumb))
                                ])),
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
                                SizedBox(
                                  height: SizeConfig.defaultSize! * 1.5,
                                ),
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                      fontSize: SizeConfig.defaultSize! * 3.5,
                                      fontFamily: 'Molengo'),
                                ),
                                SizedBox(
                                  height: SizeConfig.defaultSize! * 1.5,
                                ),
                                Row(
                                  //  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isPurchased
                                        ? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isClicked0 = false;
                                                isClicked1 = false;
                                                isClicked2 = false;
                                                canChanged = true;
                                              });
                                              widget.record!
                                                  ? inferenceId == 0
                                                      ? {
                                                          startInference(token),
                                                          setState(() {
                                                            canChanged = false;
                                                            completeInference =
                                                                false;
                                                          }),
                                                        } //인퍼런스 요청 보내기
                                                      : cvi = inferenceId
                                                  : setState(() {
                                                      goRecord = true;
                                                    });
                                            },
                                            child: Column(
                                              // 결제 한 사람
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: SizeConfig
                                                              .defaultSize! *
                                                          1),
                                                  child: Image.asset(
                                                    'lib/images/mine.png',
                                                    height: SizeConfig
                                                            .defaultSize! *
                                                        6.5,
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: SizeConfig
                                                            .defaultSize! *
                                                        1),
                                                Text('Mine',
                                                    style: TextStyle(
                                                        fontFamily: 'Molengo',
                                                        fontSize: 1.5 *
                                                            SizeConfig
                                                                .defaultSize!))
                                              ],
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                wantPurchase = true;
                                              });
                                            },
                                            child: Center(
                                              child: Column(
                                                // 결제 안 한 사람
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 0 *
                                                            SizeConfig
                                                                .defaultSize!,
                                                        left: 0 *
                                                            SizeConfig
                                                                .defaultSize!),
                                                    child: Image.asset(
                                                        'lib/images/lock.png',
                                                        height: SizeConfig
                                                                .defaultSize! *
                                                            6.5),
                                                  ),
                                                  SizedBox(
                                                      height: SizeConfig
                                                              .defaultSize! *
                                                          0.3),
                                                  Text('Mine',
                                                      style: TextStyle(
                                                          fontFamily: 'Molengo',
                                                          fontSize: 1.5 *
                                                              SizeConfig
                                                                  .defaultSize!))
                                                ],
                                              ),
                                            )),
                                    SizedBox(
                                      width: 1.5 * SizeConfig.defaultSize!,
                                    ),
                                    // Jolly
                                    GestureDetector(
                                        onTap: () {
                                          cvi = voices[0][
                                              'contentVoiceId']; // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                          setState(() {
                                            isClicked0 = true;
                                            isClicked1 = !isClicked0;
                                            isClicked2 = !isClicked0;
                                            canChanged = true; // 클릭 상태
                                          });
                                        },
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 0 *
                                                          SizeConfig
                                                              .defaultSize!),
                                                  child: isClicked0
                                                      ? Container(
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              6.6,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  255),
                                                              width: 3.5,
                                                            ),
                                                          ),
                                                          child: Image.asset(
                                                            'lib/images/jolly.png',
                                                            height: SizeConfig
                                                                    .defaultSize! *
                                                                6.5,
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          'lib/images/jolly.png',
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              6.5,
                                                        )),
                                              SizedBox(
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          0.3),
                                              Text(voices[0]['voiceName'],
                                                  style: TextStyle(
                                                      fontFamily: 'Molengo',
                                                      fontSize: 1.5 *
                                                          SizeConfig
                                                              .defaultSize!))
                                            ],
                                          ),
                                        )),
                                    SizedBox(
                                      width: 1.5 * SizeConfig.defaultSize!,
                                    ),
                                    // Morgan
                                    GestureDetector(
                                        onTap: () {
                                          cvi = voices[1][
                                              'contentVoiceId']; // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                          setState(() {
                                            isClicked1 = true;
                                            isClicked0 = !isClicked1;
                                            isClicked2 = !isClicked1;
                                            canChanged = true; // 클릭 상태
                                          });
                                        },
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 0 *
                                                          SizeConfig
                                                              .defaultSize!),
                                                  child: isClicked1
                                                      ? Container(
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              6.6,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  255),
                                                              width: 3.5,
                                                            ),
                                                          ),
                                                          child: Image.asset(
                                                            'lib/images/morgan.png',
                                                            height: SizeConfig
                                                                    .defaultSize! *
                                                                6.5,
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          'lib/images/morgan.png',
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              6.5,
                                                        )),
                                              SizedBox(
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          0.3),
                                              Text(voices[1]['voiceName'],
                                                  style: TextStyle(
                                                      fontFamily: 'Molengo',
                                                      fontSize: 1.5 *
                                                          SizeConfig
                                                              .defaultSize!))
                                            ],
                                          ),
                                        )),
                                    SizedBox(
                                      width: 1.5 * SizeConfig.defaultSize!,
                                    ),
                                    // Eric
                                    GestureDetector(
                                        onTap: () {
                                          cvi = voices[2][
                                              'contentVoiceId']; // 1, 2, 3 등 --> 이 값을 밑에 화살표 부분에 넘겨준 것
                                          setState(() {
                                            isClicked2 = true;
                                            isClicked0 = !isClicked2;
                                            isClicked1 = !isClicked2;
                                            canChanged = true; // 클릭 상태
                                          });
                                        },
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 0 *
                                                          SizeConfig
                                                              .defaultSize!),
                                                  child: isClicked2
                                                      ? Container(
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              6.6,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  255),
                                                              width: 3.5,
                                                            ),
                                                          ),
                                                          child: Image.asset(
                                                            'lib/images/eric.png',
                                                            height: SizeConfig
                                                                    .defaultSize! *
                                                                6.5,
                                                          ),
                                                        )
                                                      : Image.asset(
                                                          'lib/images/eric.png',
                                                          height: SizeConfig
                                                                  .defaultSize! *
                                                              6.5,
                                                        )),
                                              SizedBox(
                                                  height:
                                                      SizeConfig.defaultSize! *
                                                          0.3),
                                              Text(voices[2]['voiceName'],
                                                  style: TextStyle(
                                                      fontFamily: 'Molengo',
                                                      fontSize: 1.5 *
                                                          SizeConfig
                                                              .defaultSize!))
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                                Padding(
                                  // Summary
                                  padding: EdgeInsets.only(
                                      right: 1 * SizeConfig.defaultSize!,
                                      top: 1 * SizeConfig.defaultSize!),
                                  child: Text(
                                    widget.summary,
                                    style: TextStyle(
                                        fontFamily: 'Molengo',
                                        fontSize:
                                            SizeConfig.defaultSize! * 2.2),
                                  ),
                                ),
                              ],
                            ),
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
                            onTap: () async {
                              print('인퍼런스아이디');
                              print(inferenceId);
                              (cvi == inferenceId) // 원래는 cvi==inferenceId
                                  ? await checkInference(token)
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FairytalePage(
                                              // 다음 화면으로 contetnVoiceId를 가지고 이동
                                              voiceId: cvi,
                                              lastPage: lastPage,
                                              isSelected: true,
                                            ),
                                          ))
                                      : setState(() {
                                          completeInference = false;
                                        })
                                  : canChanged
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FairytalePage(
                                              // 다음 화면으로 contetnVoiceId를 가지고 이동

                                              record: widget.record!,
                                              purchase: widget.purchase!,
                                              voiceId: cvi,
                                              lastPage: lastPage,
                                              isSelected: true,
                                            ),
                                          ),
                                        )
                                      : null;
                            },
                            // next 화살표 시작
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: 0 * SizeConfig.defaultSize!,
                                  right: 0 * SizeConfig.defaultSize!,
                                  left: 20 * SizeConfig.defaultSize!),
                              child: Icon(
                                Icons.arrow_forward,
                                size: SizeConfig.defaultSize! * 3.5,
                                color: Colors.black,
                              ),
                            ),
                            // next 화살표 끝
                          ))
                    ]),
                  ), // --------------------성우 아이콘 배치 완료  ---------
                ]),
              ),
              //추가
            ),
          ),
          Visibility(
            visible: wantPurchase,
            child: AlertDialog(
              title: const Text('Register your voice!'),
              content: const Text('Click OK to go to voice registration.'),
              actions: [
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        wantPurchase = false;
                      });
                    });
                  },
                  child: const Text('later'),
                ),
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Purchase()),
                      );
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          Visibility(
            visible: goRecord,
            child: AlertDialog(
              title: const Text('Register your voice!'),
              content: const Text(
                  'After registering your voice, listen to the book with your voice.'),
              actions: [
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        goRecord = false;
                      });
                    });
                  },
                  child: const Text('later'),
                ),
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RecordInfo()),
                      );
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          Visibility(
            visible: !completeInference,
            child: AlertDialog(
              title: const Text('Please wait a minute.'),
              content: const Text(
                  "We're making a book with your voice. \nIf you want to read the book right now, please choose a different voice actor!"),
              actions: [
                TextButton(
                  onPressed: () {
                    // 1초 후에 다음 페이지로 이동
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        completeInference = true;
                      });
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ]));
  }
}
