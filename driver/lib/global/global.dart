import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver/models/Vehicle_data.dart';
import 'package:driver/models/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver/models/direction_details_info.dart';
import 'package:driver/models/user_model.dart';
import 'package:geolocator/geolocator.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
String cloudMessagingServerToken = "";
User? currentUser;
StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

UserModel? userModelCurrentInfo;
Position? driverCurrentPosition;
DriverData onlineDriverData = DriverData();
VehicleData onlineVehicleData = VehicleData();
