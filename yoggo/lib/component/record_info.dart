import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/component/home/view/home_screen.dart';
import 'package:yoggo/size_config.dart';
import './record_page2.dart';
import 'globalCubit/user/user_cubit.dart';

class RecordInfo extends StatefulWidget {
  const RecordInfo({super.key});

  @override
  _RecordInfoState createState() => _RecordInfoState();
}

String mypath = '';

class _RecordInfoState extends State<RecordInfo> {
  @override
  void initState() {
    super.initState();
    // TODO: Add initialization code
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void dispose() {
    // TODO: Add cleanup code
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userCubit = context.watch<UserCubit>();
    final userState = userCubit.state;
    SizeConfig().init(context);
    _sendRecAbstViewEvent(userState.purchase, userState.record);
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
              flex: SizeConfig.defaultSize!.toInt() * 1,
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
                  Positioned(
                    left: SizeConfig.defaultSize! * 2,
                    child: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        size: SizeConfig.defaultSize! * 2.3,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          // 설득 & 광고 페이지로 가야하는데 일단은 홈으로 빠지게 하겠음
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      //color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: SizeConfig.defaultSize!,
            ),
            Expanded(
              flex: SizeConfig.defaultSize!.toInt(),
              child: Text(
                'Now it\'s your turn to make your voice heard!',
                style: TextStyle(
                  fontSize: SizeConfig.defaultSize! * 2,
                  fontFamily: 'Molengo',
                ),
              ),
            ),
            Expanded(
              flex: SizeConfig.defaultSize!.toInt() * 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Image(
                        image: AssetImage('lib/images/quite.png'),
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize! * 2,
                      ),
                      Text(
                        "Eliminate\nambient noise\nand focus on\nyour voice",
                        style: TextStyle(
                            fontSize: SizeConfig.defaultSize! * 2,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Molengo'),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 4,
                  ),
                  Column(
                    children: [
                      const Image(
                        image: AssetImage('lib/images/speach1.png'),
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize! * 2,
                      ),
                      Text(
                        "The more of\n your voice \nwithout gaps \nthe better quality",
                        style: TextStyle(
                          fontSize: SizeConfig.defaultSize! * 2,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Molengo',
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 4,
                  ),
                  Column(
                    children: [
                      const Image(
                        image: AssetImage('lib/images/thumbsUp.png'),
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize! * 2,
                      ),
                      Text(
                        "The best quality\nwhen recorded\nfor about\n40 seconds",
                        style: TextStyle(
                          fontSize: SizeConfig.defaultSize! * 2,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Molengo',
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                  SizedBox(
                    width: SizeConfig.defaultSize! * 4,
                  ),
                  Column(
                    children: [
                      const Image(
                        image: AssetImage('lib/images/infinite.png'),
                      ),
                      SizedBox(
                        height: SizeConfig.defaultSize! * 2,
                      ),
                      Text(
                        "You can try again\nuntil you want",
                        style: TextStyle(
                          fontSize: SizeConfig.defaultSize! * 2,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Molengo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Positioned(
                      //     child: IconButton(
                      //   padding: EdgeInsets.only(
                      //       left: SizeConfig.defaultSize! * 13,
                      //       top: SizeConfig.defaultSize! * 2),
                      //   icon: Icon(
                      //     Icons.arrow_circle_right_outlined,
                      //     size: SizeConfig.defaultSize! * 4,
                      //     color: Colors.black,
                      //   ),
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const AudioRecorder(
                      //             // 다음 화면으로 contetnVoiceId를 가지고 이동
                      //             ),
                      //       ),
                      //     );
                      //   },
                      // ))
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: SizeConfig.defaultSize!.toInt() * 1,
              //child:
              //  Positioned(
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(
                        //  left: SizeConfig.defaultSize! * 13,
                        // top: SizeConfig.defaultSize! * 2,
                        right: SizeConfig.defaultSize! * 4),
                    icon: Icon(
                      Icons.arrow_circle_right_outlined,
                      size: SizeConfig.defaultSize! * 4,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AudioRecorder(
                              // 다음 화면으로 contetnVoiceId를 가지고 이동
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ), //)
          ],
        ),
      ),
    );
  }

  Future<void> _sendRecAbstViewEvent(purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'rec_abst_view',
        parameters: <String, dynamic>{
          'purchase': purchase,
          'record': record,
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
