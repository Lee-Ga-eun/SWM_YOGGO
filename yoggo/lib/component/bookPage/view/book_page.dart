import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:yoggo/component/bookPage/viewModel/book_page_cubit.dart';
import 'package:yoggo/component/bookPage/viewModel/book_page_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:yoggo/size_config.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../book_end.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../globalCubit/user/user_cubit.dart';

class BookPage extends StatefulWidget {
  final int contentVoiceId; //detail_screen에서 받아오는 것들
  final bool isSelected;
  final int lastPage;
  final int voiceId;
  final int contentId;

  const BookPage({
    super.key,
    required this.contentVoiceId, // detail_screen에서 받아오는 것들 초기화
    required this.voiceId, // detail_screen에서 받아오는 것들 초기화
    required this.contentId, // detail_screen에서 받아오는 것들 초기화
    required this.isSelected,
    required this.lastPage,
  });

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> with WidgetsBindingObserver {
  // List<BookPage> pages = []; // 책 페이지 데이터 리스트
  //List<Map<String, dynamic>> pages = [];
  int currentPageIndex = 0; // 현재 페이지 인덱스
  bool isPlaying = true;
  bool pauseFunction = false;
  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드에 들어갔을 때 실행할 로직
      audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      // 앱이 포그라운드로 복귀했을 때 실행할 로직
      resumeAudio();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Amplitude amplitude = Amplitude.getInstance();

  Future<void> fetchAllBookPages() async {
    // API에서 모든 책 페이지 데이터를 불러와 pages 리스트에 저장
    final response = await http.get(Uri.parse(
        'https://yoggo-server.fly.dev/content/page?contentVoiceId=${widget.contentVoiceId}'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is List<dynamic>) {
        setState(() {
          // pages = List<Map<String, dynamic>>.from(jsonData);
        });
      }
    } else {
      // 에러 처리
    }
  }

  void nextPage() async {
    await stopAudio();
    setState(() {
      isPlaying = true;
      //awiat stopAudio();
      pauseFunction = false;
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
        isPlaying = true;
        pauseFunction = false;
        stopAudio();
      }
    });
  }

  stopAudio() async {
    await audioPlayer.stop();
  }

  void pauseAudio() async {
    print("pause");
    //  isPlaying = false;
    await audioPlayer.stop();
    // isPlaying = false;
    // setState(() {
    //   isPlaying = true;
    // });
  }

  void resumeAudio() async {
    print("resume");
    //  isPlaying = true;
    await audioPlayer.resume();
    // isPlaying = true;
    // setState(() {
    //   isPlaying = false;
    // });
  }

  @override
  void dispose() async {
    //await stopAudio();
    audioPlayer.stop();
    audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    return BlocProvider(
        create: (context) =>
            BookPageCubit()..loadBookPageData(widget.contentVoiceId),
        child: BlocBuilder<BookPageCubit, List<BookPageModel>>(
            builder: (context, bookPage) {
          if (bookPage.isEmpty) {
            return Scaffold(
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
                    color: const Color.fromARGB(255, 255, 169, 26),
                    size: SizeConfig.defaultSize! * 10,
                  ),
                ),
              ),
            );
          } else {
            _sendBookPageViewEvent(widget.contentVoiceId, widget.contentId,
                widget.voiceId, currentPageIndex + 1);
            return WillPopScope(
              child: Scaffold(
                body: Stack(
                  children: [
                    // 현재 페이지 위젯
                    Visibility(
                      visible: true,
                      child: PageWidget(
                        // page: currentPageIndex < widget.lastPage
                        //     ? bookPage[currentPageIndex]
                        //     : bookPage[widget.lastPage - 1],
                        text: currentPageIndex < widget.lastPage
                            ? bookPage[currentPageIndex].text
                            : bookPage[widget.lastPage - 1].text,
                        imageUrl: currentPageIndex < widget.lastPage
                            ? bookPage[currentPageIndex].imageUrl
                            : bookPage[widget.lastPage - 1].imageUrl,
                        position: currentPageIndex < widget.lastPage
                            ? bookPage[currentPageIndex].position
                            : bookPage[widget.lastPage - 1].position,
                        audioUrl: bookPage[currentPageIndex].audioUrl,
                        realCurrent: true,
                        currentPage: currentPageIndex,
                        audioPlayer: audioPlayer,
                        pauseFunction: pauseFunction,
                        previousPage: previousPage,
                        currentPageIndex: currentPageIndex,
                        nextPage: nextPage,
                        lastPage: widget.lastPage,
                        voiceId: widget.voiceId,
                        contentVoiceId: widget.contentVoiceId,
                        contentId: widget.contentId,
                        isSelected: widget.isSelected,
                        dispose: dispose,
                        stopAudio: stopAudio,
                      ),
                    ),
                    // 다음 페이지 위젯
                    Offstage(
                      offstage: true, // 화면에 보이지 않도록 설정
                      child: PageWidget(
                        text: currentPageIndex < widget.lastPage
                            ? currentPageIndex == widget.lastPage - 1
                                ? bookPage[currentPageIndex].text
                                : bookPage[currentPageIndex + 1].text
                            : bookPage[widget.lastPage - 1].text,
                        imageUrl: currentPageIndex < widget.lastPage
                            ? currentPageIndex == widget.lastPage - 1
                                ? bookPage[currentPageIndex].imageUrl
                                : bookPage[currentPageIndex + 1].imageUrl
                            : bookPage[widget.lastPage - 1].imageUrl,
                        position: currentPageIndex < widget.lastPage
                            ? currentPageIndex == widget.lastPage - 1
                                ? bookPage[currentPageIndex].position
                                : bookPage[currentPageIndex + 1].position
                            : bookPage[widget.lastPage - 1].position,
                        //text: currentPageIndex<widget.lastPage? bookPage[currentPageIndex].text:bookPage[currentPageIndex+1].text,
                        //  imageUrl: currentPageIndex<widget.lastPage? bookPage[currentPageIndex].imageUrl:bookPage[currentPageIndex+1].imageUrl,
                        //  position: currentPageIndex<widget.lastPage? bookPage[currentPageIndex].position:bookPage[currentPageIndex+1].position,
                        realCurrent: false,
                        audioUrl: currentPageIndex != widget.lastPage - 1
                            ? bookPage[currentPageIndex + 1].audioUrl
                            : bookPage[currentPageIndex].audioUrl,
                        currentPage: currentPageIndex != widget.lastPage - 1
                            ? currentPageIndex + 1
                            : currentPageIndex,
                        audioPlayer: audioPlayer,
                        pauseFunction: pauseFunction,
                        previousPage: previousPage,
                        currentPageIndex: currentPageIndex,
                        nextPage: nextPage,
                        lastPage: widget.lastPage,
                        voiceId: widget.voiceId,
                        contentVoiceId: widget.contentVoiceId,
                        contentId: widget.contentId,
                        isSelected: widget.isSelected,
                        dispose: dispose,
                        stopAudio: stopAudio,
                      ),
                    ),
                    Offstage(
                      offstage: true, // 화면에 보이지 않도록 설정
                      child: PageWidget(
                        // page: currentPageIndex != 0
                        //     ? pages[currentPageIndex - 1]
                        //     : pages[0],
                        text: currentPageIndex != 0
                            ? bookPage[currentPageIndex].text
                            : bookPage[currentPageIndex + 1].text,
                        imageUrl: currentPageIndex != 0
                            ? bookPage[currentPageIndex].imageUrl
                            : bookPage[currentPageIndex + 1].imageUrl,
                        position: currentPageIndex != 0
                            ? bookPage[currentPageIndex].position
                            : bookPage[currentPageIndex + 1].position,
                        realCurrent: false,
                        audioUrl: currentPageIndex != 0
                            ? bookPage[currentPageIndex - 1].audioUrl
                            : bookPage[0].audioUrl,
                        currentPage: currentPageIndex,
                        audioPlayer: audioPlayer,
                        pauseFunction: pauseFunction,
                        previousPage: previousPage,
                        currentPageIndex: currentPageIndex,
                        nextPage: nextPage,
                        lastPage: widget.lastPage,
                        voiceId: widget.voiceId,
                        contentVoiceId: widget.contentVoiceId,
                        contentId: widget.contentId,
                        isSelected: widget.isSelected,
                        dispose: dispose,
                        stopAudio: stopAudio,
                      ),
                    ),
                  ],
                ),
                // ),
              ),
              onWillPop: () {
                stopAudio();
                return Future.value(true);
              },
            );
          }
        }));
  }

  Future<void> _sendBookPageViewEvent(
      contentVoiceId, contentId, voiceId, pageId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_page_view',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
      amplitude.logEvent(
        'book_page_view',
        eventProperties: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookPageLoadingViewEvent(
      contentVoiceId, contentId, voiceId) async {
    try {
      await analytics.logEvent(
        name: 'book_page_loading_view',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
        },
      );
      amplitude.logEvent(
        'book_page_loading_view',
        eventProperties: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}

class PageWidget extends StatefulWidget {
  //final Map<String, dynamic> page;
  final String text;
  final String imageUrl;
  final int position;
  final String audioUrl;
  final int currentPage;
  final AudioPlayer audioPlayer;
  final bool pauseFunction;
  final bool realCurrent;
  final previousPage;
  final int currentPageIndex;
  final nextPage;
  final int lastPage;
  final bool? purchase;
  final bool? record;
  final int voiceId; //detail_screen에서 받아오는 것들
  final int contentVoiceId; //detail_screen에서 받아오는 것들
  final int contentId; //detail_screen에서 받아오는 것들
  final bool isSelected;
  final dispose;
  final stopAudio;

  const PageWidget({
    Key? key,
    //  required this.page,
    required this.text,
    required this.imageUrl,
    required this.position,
    required this.audioUrl,
    required this.currentPage,
    required this.audioPlayer,
    required this.pauseFunction,
    required this.realCurrent,
    required this.previousPage,
    required this.currentPageIndex,
    required this.nextPage,
    required this.lastPage,
    this.purchase,
    required this.voiceId,
    required this.contentVoiceId,
    required this.contentId,
    required this.isSelected,
    this.record,
    required this.dispose,
    required this.stopAudio,
  }) : super(key: key);

  @override
  _PageWidgetState createState() => _PageWidgetState();
}

class _PageWidgetState extends State<PageWidget> {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Amplitude amplitude = Amplitude.getInstance();

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    void playAudio(String audioUrl) async {
      if (widget.realCurrent) {
        await widget.audioPlayer.stop();
        await widget.audioPlayer.play(UrlSource(audioUrl));
      }
    }

    playAudio(widget.audioUrl);
    //final text = widget.page['text'] as String;
    //final imageUrl = widget.page['imageUrl'];
    //final imagePostion = widget.page['position'];

    CachedNetworkImage(
      imageUrl: widget.imageUrl,
    );
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/bkground.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.defaultSize!),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      //HEADER
                      flex: 12,
                      child: Container(
                        // [X]
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: IconButton(
                                padding: EdgeInsets.all(
                                    0.2 * SizeConfig.defaultSize!),
                                alignment: Alignment.centerLeft,
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.black,
                                  size: 3 * SizeConfig.defaultSize!,
                                ),
                                onPressed: () {
                                  // stopAudio();
                                  widget.dispose();
                                  _sendBookPageXClickEvent(
                                      widget.contentVoiceId,
                                      widget.contentId,
                                      widget.voiceId,
                                      widget.currentPageIndex + 1);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            Expanded(
                              flex: 11,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '${widget.currentPageIndex + 1} / ${widget.lastPage}',
                                  style: TextStyle(
                                      fontFamily: 'GenBkBasR',
                                      fontSize: SizeConfig.defaultSize! * 2),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            )
                          ],
                        ),
                      )),
                  Expanded(
                    // BoDY
                    flex: 74,
                    child: Row(
                      children: [
                        Expanded(
                          flex: widget.position == 1 ? 1 : 2,
                          child: Container(
                            // color: Colors.red,
                            child: widget.position == 1
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child:
                                            Image.asset('lib/images/gray.png'),
                                      ),
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Padding(
                                    // 글자 - 그림
                                    padding: EdgeInsets.only(
                                        right: 1 * SizeConfig.defaultSize!,
                                        left: 1 * SizeConfig.defaultSize!),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.text,
                                            style: TextStyle(
                                                fontSize: 2.3 *
                                                    SizeConfig.defaultSize!,
                                                fontFamily: 'GenBkBasR',
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            // ), // 글자를 2번 화면에 배치
                          ),
                        ),
                        Expanded(
                          flex: widget.position == 0 ? 1 : 2,
                          child: Container(
                            //color: position == 2 ? Colors.red : Colors.white,
                            child: widget.position == 0
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child:
                                            Image.asset('lib/images/gray.png'),
                                      ),
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                //그림을 2번 화면에 배치
                                : Padding(
                                    padding: EdgeInsets.only(
                                        right: 0.5 * SizeConfig.defaultSize!,
                                        left: 2 * SizeConfig.defaultSize!),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            widget.text,
                                            style: TextStyle(
                                                fontSize:
                                                    SizeConfig.defaultSize! *
                                                        2.3,
                                                fontFamily: 'GenBkBasR',
                                                fontWeight: FontWeight.w400),
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
                  Expanded(
                    flex: 12,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            // bottom: 5,
                            // left: 10,
                            child: Container(
                              // [<-]
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.start, // 아이콘을 맨 왼쪽으로 정렬
                                children: [
                                  IconButton(
                                      padding: EdgeInsets.all(
                                          0.2 * SizeConfig.defaultSize!),
                                      icon: widget.currentPageIndex == 0
                                          ? Icon(
                                              Icons.arrow_back,
                                              color:
                                                  Colors.black.withOpacity(0),
                                            )
                                          : Icon(
                                              Icons.arrow_back,
                                              size: 3 * SizeConfig.defaultSize!,
                                            ),
                                      onPressed: () {
                                        _sendBookBackClickEvent(
                                            widget.contentVoiceId,
                                            widget.contentId,
                                            widget.voiceId,
                                            widget.currentPageIndex + 1);
                                        widget.previousPage();
                                      })
                                ],
                              ),
                            )),
                        Expanded(
                            flex: 8,
                            child: Container(
                                color: const Color.fromARGB(0, 0, 0, 0))),
                        Expanded(
                            flex: 1,
                            child: widget.currentPageIndex !=
                                    widget.lastPage - 1
                                ? Container(
                                    // [->]
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .end, // 아이콘을 맨 왼쪽으로 정렬
                                      children: [
                                        IconButton(
                                            padding: EdgeInsets.all(
                                                0.2 * SizeConfig.defaultSize!),
                                            icon: Icon(
                                              Icons.arrow_forward,
                                              size: 3 * SizeConfig.defaultSize!,
                                            ),
                                            onPressed: () {
                                              _sendBookNextClickEvent(
                                                  widget.contentVoiceId,
                                                  widget.contentId,
                                                  widget.voiceId,
                                                  widget.currentPageIndex + 1);
                                              widget.nextPage();
                                            })
                                      ],
                                    ),
                                  )
                                : Container(
                                    // [V]
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .end, // 아이콘을 맨 왼쪽으로 정렬
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(0.2 *
                                              SizeConfig
                                                  .defaultSize!), // 패딩 크기를 원하는 값으로 조정해주세요
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.check,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              size: 3 * SizeConfig.defaultSize!,
                                            ),
                                            // 결제와 목소리 등록을 완료한 사용자는 바로 종료시킨다
                                            // 결제만 한 사용자는 등록을 하라는 메시지를 보낸다 // 아직 등록하지 않았어요~~
                                            // 결제를 안 한 사용자는 결제하는 메시지를 보여준다 >> 목소리로 할 수 있아요~~
                                            onPressed: () {
                                              widget.dispose();
                                              _sendBookLastClickEvent(
                                                  widget.contentVoiceId,
                                                  widget.contentId,
                                                  widget.voiceId,
                                                  widget.currentPageIndex + 1);

                                              if (widget.record != null &&
                                                  widget.record == true &&
                                                  widget.purchase == true) {
                                                //Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookEnd(
                                                      voiceId: widget.voiceId,
                                                      contentVoiceId:
                                                          widget.contentVoiceId,
                                                      contentId:
                                                          widget.contentId,
                                                      lastPage: widget.lastPage,
                                                      isSelected:
                                                          widget.isSelected,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                Navigator.push(
                                                  context,
                                                  //결제가 끝나면 RecInfo로 가야 함
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookEnd(
                                                      contentVoiceId:
                                                          widget.contentVoiceId,
                                                      contentId:
                                                          widget.contentId,
                                                      voiceId: widget.voiceId,
                                                      lastPage: widget.lastPage,
                                                      isSelected:
                                                          widget.isSelected,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendBookPageXClickEvent(
      contentVoiceId, contentId, voiceId, pageId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_page_x_click',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
      amplitude.logEvent(
        'book_page_x_click',
        eventProperties: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookLastClickEvent(
      contentVoiceId, contentId, voiceId, pageId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_last_click',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
      amplitude.logEvent(
        'book_last_click',
        eventProperties: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookNextClickEvent(
      contentVoiceId, contentId, voiceId, pageId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_next_click',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
      amplitude.logEvent(
        'book_next_click',
        eventProperties: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookBackClickEvent(
      contentVoiceId, contentId, voiceId, pageId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_back_click',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
      amplitude.logEvent(
        'book_back_click',
        eventProperties: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
          'contentId': contentId,
          'voiceId': voiceId,
          'pageId': pageId,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
