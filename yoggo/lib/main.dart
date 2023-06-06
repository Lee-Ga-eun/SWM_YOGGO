import 'package:flutter/material.dart';
import './home_screen.dart';
import './widgets/intro.dart';
import 'package:flutter/services.dart';

void main() {
  //runApp(const App());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const App());
  });
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 6)); // 3초 동안 대기
    setState(() {
      _initialized = true; // 초기화 완료 상태 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _initialized
          ? HomeScreen()
          : const SplashScreen(), // 초기화 상태에 따라 화면 표시
    );
  }
}
