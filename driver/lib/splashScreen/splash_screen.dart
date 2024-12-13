import 'dart:async';

import 'package:flutter/material.dart';
import 'package:driver/Assistants/assistant_methods.dart';
import 'package:driver/global/global.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:driver/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() {
    Timer(const Duration(seconds: 2), () async {
      if (firebaseAuth.currentUser != null) {
        firebaseAuth.currentUser != null
            ? AssistantMethods.readCurrentOnlineUserInfo()
            : null;
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MainScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
