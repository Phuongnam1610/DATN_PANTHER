import 'package:user/Assistants/assistant_system.dart';
import 'package:user/themeProvider/AppColors.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;

  CustomText({required this.text, this.color , this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AssistantSystem.isDarkMode(context) ? Colors.white : AppColors.contentPrimary,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',

      ),
    );
  }
}