import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/Assistants/assistant_methods.dart';
import 'package:driver/global/global.dart';
import 'package:driver/models/Vehicle_data.dart';
import 'package:driver/models/driver_data.dart';
import 'package:driver/pushNotification/push_notification_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  ); // // CameraPosition

  var geolocator = Geolocator();
  LocationPermission? _locationPermission;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;
    LatLng latlngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition, zoom: 15);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressFromCoordinates(
            driverCurrentPosition!, context);
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);
    userRef.get().then((doc) {
      if (doc.exists) {
        onlineDriverData = DriverData.fromDocument(doc);

        userRef.get().then((doc) {
          if (doc.exists) {
            onlineDriverData = DriverData.fromDocument(doc);

            var vehicleOnId =
                (doc.data() as Map<String, dynamic>)["vehicleOnId"];
            var vehicleRef = FirebaseFirestore.instance
                .collection('Vehicles')
                .doc(vehicleOnId.toString());
            vehicleRef.get().then((doc) {
              if (doc.exists) {
                onlineVehicleData = VehicleData.fromDocument(doc);
              }
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentOnlineUserInfo();
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            locateDriverPosition();
          },
        ),

        // ui for online/offline driver
        statusText != 'Now Online'
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(), // Container

// button for online/offline driver
        Positioned(
          top: statusText != 'Now Online'
              ? MediaQuery.of(context).size.height * 0.45
              : 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (isDriverActive != true) {
                      driverIsOnlineNow();
                      updateDriverLocationAtRealTime();

                      setState(() {
                        statusText = 'Now Online';
                        isDriverActive = true;
                        buttonColor = Colors.transparent;
                      });
                    } else {
                      driverIsOfflineNow();
                      setState(() {
                        statusText = 'Now Offline';
                        isDriverActive = false;
                        buttonColor = Colors.grey;
                      });
                      Fluttertoast.showToast(msg: "You are offline now");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: statusText != 'Now Online'
                      ? Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.phonelink_ring,
                          color: Colors.white,
                          size: 26,
                        )),
            ],
          ), // Elevated Button
        ), // Row
// Positioned
      ],
    );
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;
// Updates an existing document's 'geo' field by giving GeoPoint instance.
    GeoCollectionReference(FirebaseFirestore.instance.collection('Users'))
        .updatePoint(
      id: currentUser!.uid,
      field: 'location',
      geopoint: GeoPoint(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude),
    );
    DocumentReference ref =
        FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);
    ref.update({
      "driverStatus": "idle",
    });

    ref.snapshots().listen((event) {});
  }

  updateDriverLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      if (isDriverActive == true) {
        driverCurrentPosition = position;
        GeoCollectionReference(FirebaseFirestore.instance.collection('Users'))
            .updatePoint(
          id: currentUser!.uid,
          field: 'location',
          geopoint: GeoPoint(driverCurrentPosition!.latitude,
              driverCurrentPosition!.longitude),
        );
      }
      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow() {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);
    ref.update({
      "status": "offline",
      "remove": ["location"]
    });

    // Future.delayed(Duration(seconds: 2), () {
    //   SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    // });
  }
}
