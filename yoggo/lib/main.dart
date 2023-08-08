import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yoggo/component/home/view/home.dart';
import 'component/globalCubit/user/user_cubit.dart';
import 'component/globalCubit/user/user_state.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'dart:io' show Platform;
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initPlatformState() async {
  await Purchases.setLogLevel(
      LogLevel.debug); // Purchases.setDebugLogsEnabled(true);

  PurchasesConfiguration? configuration;

  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration('goog_wxdljqWvkKNlMpVlNSZjKnqVtQc');
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration('appl_wPyySWQHJfhExnkjSTliaVxgpMx');
  }
  await Purchases.configure(configuration!); // Anonymous App User IDs
}

void main() async {
  // Amplitude Event 수집을 위해서 꼭 개발 모드(dev)인지 릴리즈 모드(rel)인지 설정하고 앱을 실행하도록 해요
  // 디폴트 값은 dev입니다

  String mode = 'dev';
  //String mode = 'rel';

  // 사용자 Cubit을 초기화합니다.
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding
      .ensureInitialized(); // ensureInitialized()를 호출하여 바인딩 초기화

//Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  // OneSignal.shared.setAppId(dotenv.get("ONESIGNAL"));
  Platform.isAndroid
      ? OneSignal.shared.setAppId(dotenv.get("ONESIGNAL_android"))
      : OneSignal.shared.setAppId(dotenv.get("ONESIGNAL_ios"));
  OneSignal.shared.setAppId('2d42b96d-78df-43fe-b6d1-3899c3684ac5'); //ios

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
  //   print("Accepted permission: $accepted");
  // });

  await OneSignal.shared.getDeviceState().then(
        (value) => {
          print('::::: one signal :::: ${value!.userId}'),
        },
      );
  // final Amplitude amplitude = Amplitude.getInstance();
  final Amplitude amplitude = Amplitude.getInstance();

  String AMPLITUDE_API = mode == 'rel'
      ? dotenv.get("AMPLITUDE_API_rel")
      : dotenv.get("AMPLITUDE_API_dev");

  print(AMPLITUDE_API);

  // Initialize SDK
  await amplitude.init(AMPLITUDE_API);

  await amplitude.logEvent('startup');

  await Firebase.initializeApp();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final userCubit = UserCubit();
  initPlatformState();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>.value(value: userCubit),
          // Add more Cubits here if needed
        ],
        child: const App(),
      ),
    );
  });
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initialize();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white.withOpacity(0), // 투명한 배경 색상으로 설정
    ));
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
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          //if (!state.isDataFetched) {
          //isDataFetched = true --> 데이터 불러왔단 뜻
          //return const SplashScreen(); //token이 없는 경우
          //} else {
          if (state.isDataFetched) {
            OneSignal.shared.setExternalUserId(state.userId.toString());
            Amplitude.getInstance().setUserProperties(
                {'subscribe': state.purchase, 'record': state.record});
            // 여기서 User Property 다시 한번 설정해주기 ~~
          }

          return const HomeScreen(); // token이 있는 경우
          //}
        },
      ),
    );
  }
}
