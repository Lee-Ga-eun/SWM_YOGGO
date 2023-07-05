import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import './check_voice.dart';

class WaitingVoicePage extends StatefulWidget {
  @override
  _WaitingVoicePageState createState() => _WaitingVoicePageState();
}

class _WaitingVoicePageState extends State<WaitingVoicePage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startTimer() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );

    _controller.addListener(() {
      setState(() {
        _progressValue = _controller.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 10초 후에 complete_voice.dart 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const checkVoice(),
          ),
        );
      }
    });

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: _progressValue,
            ),
            SizedBox(height: 20),
            Text(
              'Waiting for Voice...',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
