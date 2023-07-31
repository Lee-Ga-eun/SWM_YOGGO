import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/component/home/view/home_screen.dart';
import 'package:yoggo/component/reader.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/size_config.dart';
import 'package:yoggo/component/purchase.dart';

import 'globalCubit/user/user_cubit.dart';

class ReaderEnd extends StatefulWidget {
  final int voiceId; //detail_screen에서 받아오는 것들
  final bool isSelected;
  final int lastPage;
  ReaderEnd({
    super.key,
    required this.voiceId, // detail_screen에서 받아오는 것들 초기화
    required this.isSelected,
    required this.lastPage,
  });

  @override
  _ReaderEndState createState() => _ReaderEndState();
}

class _ReaderEndState extends State<ReaderEnd> {
  @override
  void initState() {
    super.initState();
    // TODO: Add initialization code
  }

  @override
  void dispose() {
    // TODO: Add cleanup code
    super.dispose();
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Amplitude amplitude = Amplitude.getInstance(instanceName: "SayIT");

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    _sendBookEndViewEvent(widget.voiceId);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/images/bkground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.defaultSize!,
            ),
            Expanded(
              flex: SizeConfig.defaultSize!.toInt(),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'LOVEL',
                        style: TextStyle(
                          fontFamily: 'Modak',
                          fontSize: SizeConfig.defaultSize! * 5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            userState.purchase != null
                ? (userState.purchase == true && userState.record == false
                    ? notRecordUser(
                        userState.purchase, userState.record, widget.voiceId)
                    : userState.purchase == true && userState.record == true
                        ? allPass()
                        : notPurchaseUser(userState.purchase, userState.record,
                            widget.voiceId))
                : Container(),
            Expanded(
                flex: SizeConfig.defaultSize!.toInt(),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                    padding:
                        EdgeInsets.only(bottom: SizeConfig.defaultSize! * 4),
                    onPressed: () {
                      _sendBookAgainClickEvent(widget.voiceId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FairytalePage(
                            // 다음 화면으로 contetnVoiceId를 가지고 이동
                            voiceId: widget.voiceId,
                            lastPage: widget.lastPage,
                            isSelected: widget.isSelected,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.replay,
                      size: SizeConfig.defaultSize! * 4,
                    ),
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 2,
                  ),
                  IconButton(
                    padding:
                        EdgeInsets.only(bottom: SizeConfig.defaultSize! * 4),
                    onPressed: () {
                      _sendBookHomeClickEvent(widget.voiceId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.home,
                      size: SizeConfig.defaultSize! * 4,
                    ),
                  ),
                ]))
          ],
        ),
      ),
    );
  }

  Expanded allPass() {
    return Expanded(
        flex: SizeConfig.defaultSize!.toInt() * 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/images/congratulate2.png',
                    width: SizeConfig.defaultSize! * 5,
                    alignment: Alignment.topCenter,
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 1.5,
                  ),
                  Text(
                    'Congratulations on \n completing the READING',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Molengo',
                        fontSize: SizeConfig.defaultSize! * 2.5),
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 2,
                  ),
                  Image.asset(
                    'lib/images/congratulate1.png',
                    width: SizeConfig.defaultSize! * 5,
                    alignment: Alignment.topCenter,
                  )
                ],
              ),
            ],
          ),
        ));
  }

  Expanded notPurchaseUser(purchase, record, cvi) {
    // 구매를 안 한 사용자
    return Expanded(
      flex: SizeConfig.defaultSize!.toInt() * 3,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/images/congratulate2.png',
                    width: SizeConfig.defaultSize! * 5,
                    alignment: Alignment.topCenter,
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 1.5,
                  ),
                  Text(
                    'Congratulations on \n completing the READING',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Molengo',
                        fontSize: SizeConfig.defaultSize! * 2.5),
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 2,
                  ),
                  Image.asset(
                    'lib/images/congratulate1.png',
                    width: SizeConfig.defaultSize! * 5,
                    alignment: Alignment.topCenter,
                  )
                ],
              ),
              SizedBox(
                height: SizeConfig.defaultSize! * 3,
              ),
              Padding(
                padding: const EdgeInsets.only(),
                child: Container(
                  // color: Colors.yellow,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(100, 255, 255, 255),
                    borderRadius: BorderRadius.all(
                        Radius.circular(SizeConfig.defaultSize! * 2)

                        // border: Border.all(
                        //   color: const Color.fromARGB(
                        //       152, 97, 1, 152), // Border의 색상을 지정합니다.
                        //   width:
                        //       SizeConfig.defaultSize! * 0.3, // Border의 두께를 지정합니다.
                        ),
                  ),
                  height: SizeConfig.defaultSize! * 13.2,
                  width: SizeConfig.defaultSize! * 66.9,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: SizeConfig.defaultSize! * 3,
                      right: SizeConfig.defaultSize! * 3,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'If you want to read a book in the voice of your parents,',
                          style: TextStyle(
                              fontFamily: 'Molengo',
                              fontSize: SizeConfig.defaultSize! * 2.3),
                        ),
                        SizedBox(
                          height: SizeConfig.defaultSize! * 1.5,
                        ),
                        InkWell(
                          onTap: () {
                            _sendBookEndPurClick(purchase, record, cvi);
                            Navigator.push(
                              context,
                              //결제가 끝나면 RecordInfo로 가야 함
                              MaterialPageRoute(
                                builder: (context) => const Purchase(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA91A),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeConfig.defaultSize! * 0.9)),
                            ),
                            width: SizeConfig.defaultSize! * 24,
                            height: 4.5 * SizeConfig.defaultSize!,
                            child: Center(
                              //Padding(
                              //   padding: EdgeInsets.only(
                              //     left: SizeConfig.defaultSize! * 5,
                              //     right: SizeConfig.defaultSize! * 5,
                              //     top: SizeConfig.defaultSize! * 0.5,
                              //     bottom: SizeConchild: fig.defaultSize! * 0.5,
                              //   ),
                              child: Text(
                                'Go to Record',
                                style: TextStyle(
                                  fontFamily: 'Molengo',
                                  fontSize: SizeConfig.defaultSize! * 2.3,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Expanded notRecordUser(purchase, record, cvi) {
    // 녹음을 안 한 사용자
    return Expanded(
      flex: SizeConfig.defaultSize!.toInt() * 3,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/images/congratulate2.png',
                    width: SizeConfig.defaultSize! * 5,
                    alignment: Alignment.topCenter,
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 1.5,
                  ),
                  Text(
                    'Congratulations on \n completing the READING',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Molengo',
                        fontSize: SizeConfig.defaultSize! * 2.5),
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 2,
                  ),
                  Image.asset(
                    'lib/images/congratulate1.png',
                    width: SizeConfig.defaultSize! * 5,
                    alignment: Alignment.topCenter,
                  )
                ],
              ),
              SizedBox(
                height: SizeConfig.defaultSize! * 3,
              ),
              Padding(
                padding: const EdgeInsets.only(),
                child: Container(
                  // color: Colors.yellow,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(100, 255, 255, 255),
                    borderRadius: BorderRadius.all(
                        Radius.circular(SizeConfig.defaultSize! * 2)

                        // border: Border.all(
                        //   color: const Color.fromARGB(
                        //       152, 97, 1, 152), // Border의 색상을 지정합니다.
                        //   width:
                        //       SizeConfig.defaultSize! * 0.3, // Border의 두께를 지정합니다.
                        ),
                  ),
                  height: SizeConfig.defaultSize! * 13.2,
                  width: SizeConfig.defaultSize! * 66.9,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: SizeConfig.defaultSize! * 3,
                      right: SizeConfig.defaultSize! * 3,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'If you want to read a book in the voice of your parents,',
                          style: TextStyle(
                              fontFamily: 'Molengo',
                              fontSize: SizeConfig.defaultSize! * 2.3),
                        ),
                        SizedBox(
                          height: SizeConfig.defaultSize! * 1.5,
                        ),
                        InkWell(
                          onTap: () {
                            _sendBookEndPurClick(purchase, record, cvi);
                            Navigator.push(
                              context,
                              //결제가 끝나면 RecordInfo로 가야 함
                              MaterialPageRoute(
                                builder: (context) => const RecordInfo(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA91A),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeConfig.defaultSize! * 0.9)),
                            ),
                            width: SizeConfig.defaultSize! * 24,
                            height: 4.5 * SizeConfig.defaultSize!,
                            child: Center(
                              //Padding(
                              //   padding: EdgeInsets.only(
                              //     left: SizeConfig.defaultSize! * 5,
                              //     right: SizeConfig.defaultSize! * 5,
                              //     top: SizeConfig.defaultSize! * 0.5,
                              //     bottom: SizeConchild: fig.defaultSize! * 0.5,
                              //   ),
                              child: Text(
                                'Go to Record',
                                style: TextStyle(
                                  fontFamily: 'Molengo',
                                  fontSize: SizeConfig.defaultSize! * 2.3,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Future<void> _sendBookEndViewEvent(contentVoiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_end_view',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
        },
      );
      amplitude.logEvent('book_end_view', eventProperties: {
        'contentVoiceId': contentVoiceId,
      });
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookEndPurClick(purchase, record, contentVoiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_end_pur_click',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
          'contentVoiceId': contentVoiceId,
        },
      );
      amplitude.logEvent('book_end_pur_click', eventProperties: {
        'purchase': purchase ? 'true' : 'false',
        'record': record ? 'true' : 'false',
        'contentVoiceId': contentVoiceId,
      });
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookAgainClickEvent(contentVoiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_again_click',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
        },
      );
      amplitude.logEvent('book_again_click',
          eventProperties: {'contentVoiceId': contentVoiceId});
    } catch (e) {
      print('Failed to log event: $e');
    }
  }

  Future<void> _sendBookHomeClickEvent(contentVoiceId) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'book_home_click',
        parameters: <String, dynamic>{
          'contentVoiceId': contentVoiceId,
        },
      );
      amplitude.logEvent('book_home_click',
          eventProperties: {'contentVoiceId': contentVoiceId});
    } catch (e) {
      print('Failed to log event: $e');
    }
  }
}
