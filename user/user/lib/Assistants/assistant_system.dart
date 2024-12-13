//thêm mã check darkmode để tái sử dụng 
import 'package:flutter/material.dart';

class AssistantSystem {
 static bool isDarkMode(BuildContext context) {
  final brightness = MediaQuery.of(context).platformBrightness;
  return brightness == Brightness.dark;
}

// Alternative method using Theme
static bool isDarkModeTheme(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}
}
