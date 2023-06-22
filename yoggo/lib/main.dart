import 'package:flutter/material.dart';
import './widgets/intro.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './login_screen.dart';

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

final String contentUrl =
    supabase.storage.from('yoggo-storage').getPublicUrl('image/'); // 책 목록 사진들

final String supabaseAudioUrl =
    supabase.storage.from('yoggo-storage').getPublicUrl('audio/'); // 책 목록 사진들

// 이미지 다운로드 받기
// final Uint8List file =
//     supabase.storage.from('public/yoggo-storage').download('image.png');

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
          //  ? const HomeScreen()
          ? const LoginScreen()
          : const SplashScreen(), // 초기화 상태에 따라 화면 표시
    );
  }
}
