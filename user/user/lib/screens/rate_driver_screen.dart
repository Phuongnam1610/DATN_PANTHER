import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:user/global/global.dart';
import 'package:user/splashScreen/splash_screen.dart';

class RateDriverScreen extends StatefulWidget {
  String? assignedDriverId;
  String? rideId;
  RateDriverScreen({super.key, this.assignedDriverId, this.rideId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  double countRatingStars = 0;
  String titleStarsRating = "Very Bad";
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Rounded Rectangle Border
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ), // BoxDecoration
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 22.3),
            Text(
              "Đánh giá tài xế",
              style: TextStyle(
                fontSize: 22,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ), // TextStyle
            ), // Text
            SizedBox(height: 20),
            Divider(
                thickness: 2,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue),
            SizedBox(height: 20),
            SmoothStarRating(
              rating: countRatingStars,
              allowHalfRating: false,
              starCount: 5,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              borderColor: darkTheme ? Colors.amber.shade400 : Colors.grey,
              size: 46,
              onRatingChanged: (valueOfStarsChoosed) {
                setState(() {
                  countRatingStars = valueOfStarsChoosed;
                  if (countRatingStars == 1) {
                    titleStarsRating = "Very Bad";
                  } else if (countRatingStars == 2) {
                    titleStarsRating = "Bad";
                  } else if (countRatingStars == 3) {
                    titleStarsRating = "Good";
                  } else if (countRatingStars == 4) {
                    titleStarsRating = "Very Good";
                  } else if (countRatingStars == 5) {
                    titleStarsRating = "Excellent";
                  }
                });
              },
            ),
            SizedBox(height: 19.3),
            Text(
              titleStarsRating,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: darkTheme ? Colors.white30 : Colors.black,
              ),
            ), // Text
            SizedBox(height: 20.1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập bình luận (tùy chọn)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.1),
            ElevatedButton(
              onPressed: () async {
                final docRef=FirebaseFirestore.instance.collection("Rating").doc(widget.rideId);
                await docRef.set({
                  "rideId": widget.rideId,
                  "driverId": widget.assignedDriverId,
                  "rating": countRatingStars,
                  "comment": _commentController.text,
                  "createdAt": DateTime.now()});
                Fluttertoast.showToast(msg: "Đánh giá thành công!");
                updateDriverRating(widget.assignedDriverId);
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (c) => SplashScreen()),
                       (route) => false
                    );
                
                // }).then((value) {
                //   updateDriverRating(widget.assignedDriverId);
                // });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    darkTheme ? Colors.amber.shade400 : Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 70),
              ),
              child: Text(
                "Submit",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.black : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateDriverRating(String? driverId) async {
    if (driverId == null) return;
    var driverRef = FirebaseFirestore.instance.collection("User").doc(driverId);
    await driverRef.get().then((value) async {
      
      if (value.exists) {
        if (value.data()!["rating"] == null) {
          await driverRef.update({
            "rating": countRatingStars,
          });
        } else {
          double currentRating = value.data()!["rating"].toDouble();
          double newRating = (currentRating + countRatingStars) / 2;
          await driverRef.update({
            "rating": newRating,
          });
        }
         
      }
    });
  }
}