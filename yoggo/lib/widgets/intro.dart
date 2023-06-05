import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static var splashUp = true;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   print('초기화');
  //   initialization();
  // }

  // void initialization() async {
  //   // print('ready in 3...');
  //   await Future.delayed(const Duration(seconds: 3));
  //   print('go!');
  //   FlutterNativeSplash.remove();
  //   SplashScreen.splashUp = false;
  //   print(SplashScreen.splashUp);
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow, // Set the background color to yellow
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
              const Text(
                'YOGGO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Welcome to YOGGO!',
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
