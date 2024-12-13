import 'package:user/themeProvider/AppColors.dart';
import 'package:flutter/material.dart';

// Lớp AppTheme định nghĩa các chủ đề cho ứng dụng
class AppTheme {
  // Định nghĩa chủ đề sáng cho ứng dụng
  static final lightTheme = ThemeData(
      // Đặt màu chính cho ứng dụng là màu primary từ AppColors
      primaryColor: AppColors.primary,
      brightness: Brightness
          .light, // Đặt màu nền cho Scaffold là màu lightBackground từ AppColors
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: 'Poppins',
      
      textTheme: TextTheme(
        bodyMedium: const TextStyle(fontWeight: FontWeight.w600), // Add this line
        bodyLarge: const TextStyle(fontWeight: FontWeight.w500), //and this
        headlineMedium: const TextStyle(fontWeight: FontWeight.w500), // and this
      
        // Add other text styles as needed, setting fontWeight to w500
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(10),
        hintStyle: const TextStyle(
          color: Color(0xffD0D0D0),
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xffD0D0D0),
              width: 2,
            )),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xffD0D0D0),
            width: 2,
          ),
        ),
      ),
      // Cấu hình chủ đề cho ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              // Đặt màu nền cho ElevatedButton là màu primary từ AppColors
              backgroundColor: AppColors.primary,
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ))));
  static final darkTheme = ThemeData(
      // Đặt màu chính cho ứng dụng là màu primary từ AppColors
      primaryColor: AppColors.primary,
      brightness: Brightness
          .dark, // Đặt màu nền cho Scaffold là màu lightBackground từ AppColors
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        bodyMedium: const TextStyle(fontWeight: FontWeight.w500), // Add this line
        bodyLarge: const TextStyle(fontWeight: FontWeight.w500), //and this
        headlineMedium: const TextStyle(fontWeight: FontWeight.w500), // and this
        // Add other text styles as needed, setting fontWeight to w500
      ),
      // Cấu hình chủ đề cho ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              // Đặt màu nền cho ElevatedButton là màu primary từ AppColors
              backgroundColor: AppColors.errorColor,
              textStyle:  TextStyle(
                fontSize: 1,
                fontWeight: FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ))));

  // Định nghĩa chủ đề tối cho ứng dụng
}
