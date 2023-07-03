import 'package:flutter/material.dart';
import 'package:yoggo/size_config.dart';
import './record_info.dart';
import 'dart:async';
import 'package:record/record.dart';

class RecordPage1 extends StatefulWidget {
  const RecordPage1({super.key});

  @override
  _RecordPage1State createState() => _RecordPage1State();
}

enum RecordingStatus {
  Recording,
  Paused,
  Stopped,
}

class _RecordPage1State extends State<RecordPage1> {
  @override
  void initState() {
    super.initState();
    // TODO: Add initialization code
  }

  // @override
  // void dispose() {
  //   // TODO: Add cleanup code
  //   super.dispose();
  // }
  int seconds = 0;
  Timer? timer;
  RecordingStatus recordingStatus = RecordingStatus.Stopped;

  void startTimer() {
    print('start');
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void resetTimer() {
    setState(() {
      seconds = 0;
    });
  }

  void toggleRecordingStatus() {
    setState(() {
      if (recordingStatus == RecordingStatus.Recording) {
        recordingStatus = RecordingStatus.Paused;
      } else {
        recordingStatus = RecordingStatus.Recording;
      }
    });
  }

  void stopRecording() {
    setState(() {
      recordingStatus = RecordingStatus.Stopped;
    });
    // Perform navigation to the next page here
  }

  @override
  void dispose() {
    timer?.cancel();
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
                          // 설득 & 광고 페이지로 가야하는데 일단은 홈으로 빠지게 하겠음
                          MaterialPageRoute(
                            builder: (context) => const RecordInfo(),
                          ),
                        );
                      },
                      //color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text('잠시'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: recordingStatus == RecordingStatus.Recording
                          ? const Icon(
                              Icons.stop,
                              size: 30,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.fiber_manual_record,
                              color: Colors.red,
                              size: 30,
                            ),
                      onPressed: () {
                        toggleRecordingStatus();
                        if (recordingStatus == RecordingStatus.Recording) {
                          startTimer();
                        } else if (recordingStatus == RecordingStatus.Paused) {
                          stopTimer();
                        }
                      },
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      recordingStatus == RecordingStatus.Recording
                          ? '$seconds seconds'
                          : seconds == 0
                              ? 'Start Recording!'
                              : 'Complete!',
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.green,
                        size: 30,
                      ),
                      onPressed: () {
                        resetTimer();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
