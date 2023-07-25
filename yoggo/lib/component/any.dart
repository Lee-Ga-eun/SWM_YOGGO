import 'package:flutter/material.dart';
//import 'package:yoggo/component/globalCubit/user/user_cubit.dart';
import 'package:yoggo/component/globalCubit/user/user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Any extends StatefulWidget {
  const Any({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Any> {
  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text("홈"),
      ),
      body: Center(
        child: Text("${userState.userName}님, 환영합니다!"),
      ),
    );
  }
}
