import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:user/models/direction_details_info.dart';
import 'package:user/models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
String cloudMessagingServerToken = "";
User? currentUser;
UserModel? userModelCurrentInfo;
List driversList = [];
DirectionDetailsInfo? tripDirectionDetailsInfo;
String userDropOffAddress = "";

double countRatingStars = 0.0;
String titleStarsRating = "";
//luồng theo dõi danh sách tài xế gần nhất đang hoạt động
StreamSubscription<List<DocumentSnapshot<Map<String, dynamic>>>>? streamOfListNearestActiveDrivers;

Position? userCurrentPosition;
