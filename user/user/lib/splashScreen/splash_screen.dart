import 'dart:async';

import 'package:flutter/material.dart';
import 'package:user/Assistants/assistant_methods.dart';
import 'package:user/global/global.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/main_screen.dart';
import 'package:user/themeProvider/AppColors.dart';

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
            if(mounted){
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MainScreen()));}
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
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Image.asset(
          "images/panther_logo.png",
        ),
      ),
    );
  }
}
