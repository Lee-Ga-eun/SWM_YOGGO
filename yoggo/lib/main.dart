import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yoggo/component/intro.dart';
import 'component/globalCubit/user/user_cubit.dart';
import 'component/globalCubit/user/user_state.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // 사용자 Cubit을 초기화합니다.
  WidgetsFlutterBinding
      .ensureInitialized(); // ensureInitialized()를 호출하여 바인딩 초기화

  await Firebase.initializeApp();

  final userCubit = UserCubit();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>.value(value: userCubit),
          // Add more Cubits here if needed
        ],
        child: const MyApp(),
      ),
    );
  });

  // runApp(
  //   MultiBlocProvider(
  //     providers: [
  //       BlocProvider<UserCubit>.value(value: userCubit),
  //       // Add more Cubits here if needed
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: BlocBuilder<UserCubit, UserState>(
//         builder: (context, state) {
//           if (!state.isDataFetched) {
//             return const SplashScreen();
//           } else {
//             return const HomeScreen();
//           }
//         },
//       ),
//     );
//   }
// }
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initialize();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
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
      home: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (!state.isDataFetched) {
            return const SplashScreen();
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}
