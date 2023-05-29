import 'package:flutter/material.dart';
import './home_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // 기초적인 위젯이며 화면에 띄어주는 역할 정도만 한다
  //build 메소드 필요
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}
