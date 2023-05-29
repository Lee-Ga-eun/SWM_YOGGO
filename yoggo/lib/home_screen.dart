import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 컬러
      appBar: AppBar(
        elevation: 0, // 음영 제거
        backgroundColor: Colors.yellow, // App Bar 컬러지정
        title: const Text(
          "YOGGO",
          style: TextStyle(
            color: Colors.black,
            //fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
