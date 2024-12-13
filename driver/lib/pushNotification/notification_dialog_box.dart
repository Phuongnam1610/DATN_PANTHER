import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/Assistants/assistant_methods.dart';
import 'package:driver/global/global.dart';
import 'package:driver/models/user_ride_request_information.dart';
import 'package:driver/screens/new_trip_screeen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;
  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ), // RoundedRectangleBorder
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
          margin: EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: darkTheme ? Colors.black : Colors.white,
          ), // BoxDecoration
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                onlineVehicleData.vehicleTypeID == "LeVRrOaz6Epk9eIpfweB"
                    ? "images/Car.png"
                    : onlineVehicleData.vehicleTypeID == "cng"
                        ? "images/cng.png"
                        : "images/bike.png",
              ),
              SizedBox(
                height: 10,
              ),
              //title
              Text(
                "New Ride Request",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                ), // TextStyle
              ), // Text
              SizedBox(height: 14),
              Divider(
                height: 2,
                thickness: 2,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "images/origin.png",
                          width: 30,
                          height: 30,
                        ), // Image.asset
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.userRideRequestDetails!.originAddress!,
                              style: TextStyle(
                                fontSize: 16,
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.blue,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/destination.png",
                          width: 30,
                          height: 30,
                        ), // Image.asset
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget
                                  .userRideRequestDetails!.destinationAddress!,
                              style: TextStyle(
                                fontSize: 16, // Corrected fontSize
                                color: darkTheme
                                    ? Colors.amber.shade400
                                    : Colors.blue,
                              ), // TextStyle
                            ), // Text
                          ), // Container
                        ), // Expanded
                      ],
                    )
                  ],
                ),
              ),
              Divider(
                height: 2,
                thickness: 2,
                color: darkTheme ? Colors.amber.shade600 : Colors.blue,
              ), // Divider

//buttons for cancelling and accepting the ride request
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        "Cancel".toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                        ), // TextStyle
                      ), // Text
                    ), // ElevatedButton
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();
                        acceptRideRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(
                        "Accept".toUpperCase(),
                        style: TextStyle(
                          fontSize: 15,
                        ), // TextStyle
                      ), // Text
                    ) // ElevatedButton
                  ],
                ), // Row
              ) // Padding
            ],
          )), // Container
    ); // Dialog
  }

  acceptRideRequest(BuildContext context) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(firebaseAuth.currentUser!.uid)
        .get()
        .then((value) {
      var data = value.data()! as Map<String, dynamic>;
      if (data["status"] == "idle") {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(firebaseAuth.currentUser!.uid)
            .update({"status": "accepted"});
        AssistantMethods.pauseLiveLocationUpdates();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => NewTripScreen()));
      } else {
        Fluttertoast.showToast(msg: "This Ride Request do not exists.");
      }
    });
  }
}
