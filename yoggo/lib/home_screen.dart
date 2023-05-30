import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void pointFunction() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 전체 컬러
      appBar: AppBar(
        // actions: 오른쪽 사이드바, leading: 왼쪽 사이드바
        elevation: 0, // 음영 제거
        backgroundColor: Colors.yellow, // App Bar 컬러지정
        title: const Text(
          "YOGGO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.money_rounded),
            onPressed: pointFunction,
            iconSize: 40,
            color: Colors.white,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: pointFunction,
              icon: const Icon(
                Icons.home,
                size: 30,
              ),
            ),
          )
        ],
      ),
    );
  }
}
