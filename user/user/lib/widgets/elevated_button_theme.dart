import 'package:user/themeProvider/AppColors.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final double? minWidth;
  final double? height;


  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textStyle,
    this.borderRadius = 8.0,
    this.elevation,
    this.padding,
    this.minWidth,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary700,
        textStyle: textStyle,
        elevation: elevation,
        padding: padding,
        minimumSize: Size(minWidth ?? double.infinity, height ?? 48), // Default height 48
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
        ),
      ),
      child: Text(text,style: TextStyle(color: Colors.white),),
    );
  }
}