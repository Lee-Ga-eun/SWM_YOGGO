import 'package:flutter/material.dart';
import './check_voice.dart';

class WaitingVoicePage extends StatefulWidget {
  const WaitingVoicePage({super.key});

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
      duration: const Duration(seconds: 10),
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
            builder: (context) =>  checkVoice(),
          ),
        );
      }
    });

    _controller.forward();
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: _progressValue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Waiting for Voice...',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 5),
              const Text(
                'Expecting 10s',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
