import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/component/home/view/home_screen.dart';
import 'package:yoggo/size_config.dart';
import './record_page2.dart';
import 'globalCubit/user/user_cubit.dart';
import 'package:amplitude_flutter/amplitude.dart';

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
  final Amplitude amplitude = Amplitude.getInstance(instanceName: "SayIT");

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
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
                // HEADER
                flex: 14,
                child: Row(children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.clear,
                                size: 2.5 * SizeConfig.defaultSize!),
                            onPressed: () {
                              Navigator.push(
                                context,
                                // 설득 & 광고 페이지로 가야하는데 일단은 홈으로 빠지게 하겠음
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                          )
                        ]),
                  ),
                  Expanded(
                    flex: 8,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 아이콘을 맨 왼쪽으로 정렬
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
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(color: const Color.fromARGB(0, 0, 0, 0)))
                ])),
            Expanded(
                flex: 74,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 1.5 * SizeConfig.defaultSize!,
                      ),
                      Text(
                        'Now it\'s your turn to make your voice heard!',
                        style: TextStyle(
                          fontSize: SizeConfig.defaultSize! * 2.2,
                          fontFamily: 'Molengo',
                        ),
                      ),
                      SizedBox(
                        height: 1.8 * SizeConfig.defaultSize!,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
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
                          ])
                    ])),
            Expanded(
              flex: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(color: const Color.fromARGB(0, 0, 100, 0)),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(color: const Color.fromARGB(0, 0, 100, 0)),
                  ),
                  Expanded(
                      flex: 1,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              padding: EdgeInsets.only(
                                  //  left: SizeConfig.defaultSize! * 13,
                                  // top: SizeConfig.defaultSize! * 2,
                                  right: SizeConfig.defaultSize! * 4),
                              icon: Icon(
                                Icons.arrow_forward,
                                size: 3 * SizeConfig.defaultSize!,
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
                          ])),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> _sendRecAbstViewEvent(purchase, record) async {
    try {
      // 이벤트 로깅
      await analytics.logEvent(
        name: 'rec_abst_view',
        parameters: <String, dynamic>{
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
      await amplitude.logEvent(
        'rec_abst_view',
        eventProperties: {
          'purchase': purchase ? 'true' : 'false',
          'record': record ? 'true' : 'false',
        },
      );
    } catch (e) {
      // 이벤트 로깅 실패 시 에러 출력
      print('Failed to log event: $e');
    }
  }
}
