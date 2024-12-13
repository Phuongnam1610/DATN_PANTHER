import 'dart:ui';
import 'package:user/themeProvider/AppColors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Stack(
          children: [
            Positioned.fill(child: Center(
              child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
            ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               TextButton(
                    onPressed: onBackPressed,
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Back",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.contentSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                
              ],
            ),
           // Center the title
              
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100.0); // Adjust height to match container
}