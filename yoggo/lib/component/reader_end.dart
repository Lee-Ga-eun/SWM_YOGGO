import 'package:flutter/material.dart';
import 'package:yoggo/component/home_screen.dart';
import 'package:yoggo/component/reader.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/size_config.dart';

class ReaderEnd extends StatefulWidget {
  final int voiceId; //detail_screen에서 받아오는 것들
  final bool isSelected;
  final int lastPage;
  const ReaderEnd({
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
                          fontFamily: 'BreeSerif',
                          fontSize: SizeConfig.defaultSize! * 4,
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
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Congratulations!\n\n',
                              style: TextStyle(
                                  fontSize: 40.0, color: Colors.black),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
            Expanded(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                onPressed: () {
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
                  size: SizeConfig.defaultSize! * 8,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.home_rounded,
                  size: SizeConfig.defaultSize! * 8,
                ),
              )
            ]))
          ],
        ),
      ),
    );
  }
}
