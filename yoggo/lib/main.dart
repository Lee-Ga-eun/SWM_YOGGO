import 'package:flutter/material.dart';
import './home_screen.dart';
import './widgets/intro.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  //runApp(const App());
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['ANON_KEY']!,
  );

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const App());
  });
}

final supabase = Supabase.instance.client; // 슈퍼베이스
  var file; 
  Future<void> downloadImage() async { // 이미지 다운로드 받기
    final Uint8List files =
        await supabase.storage.from('public/yoggo-storage').download('image.png');

    if (files != null) {
      file = files;
      // 이곳에서 bytes를 원하는 방식으로 처리하거나 출력합니다.
      print(file);
    } else {
      print('Failed to download image.');
    }
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

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Firebase 초기화 실패 시 에러 처리
      print('Failed to initialize Firebase: $e');
    }
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
