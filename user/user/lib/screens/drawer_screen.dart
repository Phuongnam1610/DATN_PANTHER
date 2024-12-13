import 'package:flutter/material.dart';
import 'package:user/global/global.dart';
import 'package:user/screens/chat_screen.dart';
import 'package:user/screens/profile_screen.dart';
import 'package:user/screens/trip_history_screen.dart';
import 'package:user/splashScreen/splash_screen.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 50, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ), // BoxDecoration
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ), // Icon
                  ), // Container
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    userModelCurrentInfo!.name!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => ProfileTabPage()));
                    },
                    child: Text(
                      "Chỉnh sửa hồ sơ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => TripsHistoryScreen()));
                    },
                    child: Text(
                      "Lịch sử chuyến đi",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  // SizedBox(
                  //   height: 15,
                  // ),
                  // Text(
                  //   "Payment",
                  //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  // ),
                  // SizedBox(
                  //   height: 15,
                  // ),
                  // Text(
                  //   "Notifications",
                  //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  // ),
                  // SizedBox(
                  //   height: 15,
                  // ),
                  // Text(
                  //   "Promo",
                  //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  // ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (c) => ChatScreen()));
                    },
                    child: Text(
                      "Hỗ trợ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  // Text(
                  //   "Free Trips",
                  //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  // ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async{
                  await firebaseAuth.signOut();
                  streamOfListNearestActiveDrivers?.cancel();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => SplashScreen()));
                },
                child: Text(
                  "Đăng xuất",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
