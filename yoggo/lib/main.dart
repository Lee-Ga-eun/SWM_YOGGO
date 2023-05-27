import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  // 기초적인 위젯이며 화면에 띄어주는 역할 정도만 한다
  //build 메소드 필요
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              title: Text('Hello YOGGO Bar!'),
              ),
          body: Center(
            child: Text('Hello world'),
          )),
    );
  }
}
