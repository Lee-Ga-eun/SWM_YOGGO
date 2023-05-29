import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // 음영 제거
        backgroundColor: Colors.yellow,
        title: const Text(
          "YOGGO",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
