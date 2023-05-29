import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubbles Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BubbleAnimationScreen(),
    );
  }
}

class BubbleAnimationScreen extends StatefulWidget {
  @override
  _BubbleAnimationScreenState createState() => _BubbleAnimationScreenState();
}

class _BubbleAnimationScreenState extends State<BubbleAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bubbles Animation'),
      ),
      body: AnimatedBackground(
        vsync: this,
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ),
        behaviour: BubblesBehaviour(),
       // animationController: _controller,
      ),
    );
  }
}