import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/global/global.dart';
import 'package:driver/models/user_ride_request_information.dart';
import 'package:driver/pushNotification/notification_dialog_box.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging(BuildContext context) async {
    //1. Terminated
    // When the app is closed and opened directly from the push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(
            remoteMessage.data['rideRequestId'], context);
      }
    });

    //2. Foreground
    // When the app is open and receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
          remoteMessage!.data['rideRequestId'], context);
    });

    //3. Background
    // When the app is in the background and opened directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
          remoteMessage!.data['rideRequestId'], context);
    });
  }

  readUserRideRequestInformation(
      String userRideRequestId, BuildContext context) {
    FirebaseFirestore.instance
        .collection("rides")
        .doc(userRideRequestId)
        .get()
        .then((snapData) {
      if (snapData.exists) {
        final driverId = snapData.data()?["driverId"];
        if (driverId == "waitting" ||
            driverId == firebaseAuth.currentUser!.uid) {
          AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
          audioPlayer.open(Audio("assets/audio/notification.mp3"));
          audioPlayer.play();

          double originLat =
              double.parse(snapData.data()?["origin"]["latitude"]);
          double originLng =
              double.parse(snapData.data()?["origin"]["longitude"]);
          String originAddress = snapData.data()?["originAddress"];

          double destinationLat =
              double.parse(snapData.data()?["destination"]["latitude"]);
          double destinationLng =
              double.parse(snapData.data()?["destination"]["longitude"]);
          String destinationAddress = snapData.data()?["destinationAddress"];

          String userName = snapData.data()?["username"];
          String userPhone = snapData.data()?["userphone"];
          String rideRequestId = userRideRequestId;

          UserRideRequestInformation userRideRequestDetails =
              UserRideRequestInformation();
          userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
          userRideRequestDetails.originAddress = originAddress;
          userRideRequestDetails.destinationLatLng =
              LatLng(destinationLat, destinationLng);
          userRideRequestDetails.destinationAddress = destinationAddress;
          userRideRequestDetails.userName = userName;
          userRideRequestDetails.userPhone = userPhone;
          userRideRequestDetails.rideRequestId = rideRequestId;
          showDialog(
              context: context,
              builder: (BuildContext context) => NotificationDialogBox(
                    userRideRequestDetails: userRideRequestDetails,
                  ));
        } else {
          Fluttertoast.showToast(msg: "This Ride Request Id do not exists.");
        }
      } else {
        Fluttertoast.showToast(msg: "This Ride Request has been cancelled");
        Navigator.pop(context);
      }
    });
  }

  Future<void> generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM registration Token: $registrationToken");
    FirebaseFirestore.instance
        .collection("Users")
        .doc(firebaseAuth.currentUser!.uid)
        .update({"token": registrationToken});
    messaging.subscribeToTopic(
        "allDrivers"); //đăng ký người dùng hiện tại vào chủ đề allDrivers
    //Cho phép ứng dụng gửi thông báo push đến tất cả người dùng đã đăng ký vào chủ đề này

    messaging.subscribeToTopic("allUsers");
  }
}
