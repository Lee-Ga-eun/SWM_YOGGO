import 'package:flutter/material.dart';
import 'package:yoggo/component/home_screen.dart';
import 'package:yoggo/component/purchase.dart';
import 'package:yoggo/component/reader.dart';
import 'package:yoggo/component/record_info.dart';
import 'package:yoggo/size_config.dart';

class ReaderEnd extends StatefulWidget {
  final int voiceId; //detail_screen에서 받아오는 것들
  final bool isSelected;
  bool? purchase, record;
  final int lastPage;
  ReaderEnd({
    super.key,
    required this.voiceId, // detail_screen에서 받아오는 것들 초기화
    required this.isSelected,
    required this.lastPage,
    this.record,
    this.purchase,
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
            widget.purchase != null
                ? (widget.purchase == true && widget.record == false
                    ? notRecordUser()
                    : notPurchaseUser())
                : Container(),
            Expanded(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FairytalePage(
                          // 다음 화면으로 contetnVoiceId를 가지고 이동
                          voiceId: widget.voiceId,
                          lastPage: widget.lastPage,
                          isSelected: widget.isSelected,
                          record: widget.record,
                          purchase: widget.purchase,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.replay,
                    size: SizeConfig.defaultSize! * 5,
                    color: const Color.fromARGB(255, 183, 88, 199),
                  ),
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  child: Image.asset(
                    'lib/images/homeIcon.png',
                    width: SizeConfig.defaultSize! * 9,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
              ),
            ]))
          ],
        ),
      ),
    );
  }

  Expanded notPurchaseUser() {
    // 구매를 안 한 사용자
    return Expanded(
      flex: 3,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Did you enjoy the reading?',
                style: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 175, 101, 188),
                    fontFamily: 'BreeSerif'),
              ),
              const SizedBox(height: 30),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      //결제가 끝나면 RecordInfo로 가야 함
                      MaterialPageRoute(
                        builder: (context) => const Purchase(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(bottom: 15, top: 15),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 175, 101, 188),
                      // minimumSize: const Size(400, 40), // 버튼의 최소 크기를 지정
                      maximumSize: const Size(450, 100)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Experience this book with your own voice!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            fontFamily: 'BreeSerif'),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        size: 25,
                      )
                    ],
                  )),
            ],
          )),
    );
  }

  Expanded notRecordUser() {
    // 구매를 안 한 사용자
    return Expanded(
      flex: 3,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Did you enjoy the reading?',
                style: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 175, 101, 188),
                    fontFamily: 'BreeSerif'),
              ),
              const SizedBox(height: 30),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      //결제가 끝나면 RecordInfo로 가야 함
                      MaterialPageRoute(
                        builder: (context) => const RecordInfo(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(bottom: 15, top: 15),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 175, 101, 188),
                      // minimumSize: const Size(400, 40), // 버튼의 최소 크기를 지정
                      maximumSize: const Size(450, 100)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You did not register your voice yet!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            fontFamily: 'BreeSerif'),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        size: 25,
                      )
                    ],
                  )),
            ],
          )),
    );
  }
}
