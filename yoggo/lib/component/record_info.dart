import 'package:flutter/material.dart';
import 'package:yoggo/component/home_screen.dart';
import 'package:yoggo/size_config.dart';
import './record_page2.dart';

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

  @override
  void dispose() {
    // TODO: Add cleanup code
    super.dispose();
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
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.defaultSize!,
            ),
            Expanded(
              flex: 1,
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
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.cancel),
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
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    'Now it\'s your turn to make your voice heard!\n\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'You can try again until you get a performance you like\n\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text:
                                    'The best quality when recorded for about ',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text: '40 seconds',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    '\nEliminate ambient noise and focus on your voice\n',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text: 'The more of ',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                              TextSpan(
                                text: 'your voice without gaps',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: ', the better the quality.',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            TextButton(
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 175, 101, 188),
                minimumSize: const Size(400, 40), // 버튼의 최소 크기를 지정
              ),
              child: const Text(
                "Let's make it",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
                child: Text(
                    'Don’t worry! The recorded voice is never accessed by others.'))
          ],
        ),
      ),
    );
  }
}
