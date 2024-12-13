import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user/Assistants/assistant_request.dart';
import 'package:user/global/global.dart';
import 'package:user/global/map_key.dart';
import 'package:user/infoHandler/app_info.dart';
import 'package:user/models/direction_details_info.dart';
import 'package:user/models/directions.dart';
import 'package:user/models/trips_history_model.dart';
import 'package:user/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class AssistantMethods {
  static GeoPoint geopointFrom(Map<String, dynamic> data) {
    return (data['location'] as Map<String, dynamic>)['geopoint'] as GeoPoint;
  }
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('User').doc(currentUser!.uid);
    userRef.get().then((doc) {
      if (doc.exists) {
        userModelCurrentInfo = UserModel.fromDocument(doc);
      }
    });
  }

  static Future<String> searchAddressFromCoordinates(
      Position position, context) async {
    String apiUrl =
        'https://maps.gomaps.pro/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$map_key';
    String humanReadableAddress = '';

    var response = await RequestAssistant.receiveRequest(apiUrl);
    if (response != "Error Occurred. Failed. No Response.") {
      humanReadableAddress = response['results'][0]['formatted_address'];
    }
    Directions userPickUpAddress = Directions();
    userPickUpAddress.locationLatitude = position.latitude;
    userPickUpAddress.locationLongitude = position.longitude;
    userPickUpAddress.locationName = humanReadableAddress;
    Provider.of<AppInfo>(context, listen: false)
        .updatePickUpLocationAddress(userPickUpAddress);
    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    
    String urlOriginToDestinationDirectionDetails =
        "https://maps.gomaps.pro/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$map_key&mode=driving";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Error Occurred. Failed. No Response.") {
      return null;
    }
    if(responseDirectionApi['status'] !="OK"){
      // return obtainOriginToDestinationDirectionDetails(originPosition, destinationPosition);
      // return  ;
      return null;
    }

    

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi['routes'] [0]['overview_polyline']['points'];

    directionDetailsInfo.distance_text =
        responseDirectionApi['routes'][0]['legs'][0]['distance']['text'];
    directionDetailsInfo.distance_value =
        responseDirectionApi['routes'][0]['legs'][0]['distance']['value'];

    directionDetailsInfo.duration_text =
        responseDirectionApi['routes'][0]['legs'][0]['duration']['text'];
    directionDetailsInfo.duration_value =
        responseDirectionApi['routes'][0]['legs'][0]['duration']['value'];

    return directionDetailsInfo;
  }

  static Future<double> calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo, String vehicleType) async {
    var data = await FirebaseFirestore.instance
        .collection("VehicleType")
        .doc(vehicleType)
        .get();
    double baseFare = (data.data()!['baseFare']).toDouble();
    double fareFor10km = (data.data()!['fareFor10km']).toDouble();
    double fareFor5km = (data.data()!['fareFor5km']).toDouble();
    double farePerkm = (data.data()!['farePerkm']).toDouble();
    double multiplier = (data.data()!['multiplier']).toDouble();
    // double timeTraveledFareAmountPerMinute =
    // (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.distance_value! / 1000);
    double totalFareAmount = 0;
    if (distanceTraveledFareAmountPerKilometer <= 5) {
      totalFareAmount =
          (baseFare + (distanceTraveledFareAmountPerKilometer * fareFor5km));
    } else if (distanceTraveledFareAmountPerKilometer > 5 &&
        distanceTraveledFareAmountPerKilometer <= 10) {
      totalFareAmount =
          (baseFare + (distanceTraveledFareAmountPerKilometer * fareFor10km));
    } else {
      totalFareAmount =
          (baseFare + (distanceTraveledFareAmountPerKilometer * farePerkm));
    }
    totalFareAmount = totalFareAmount * multiplier;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static sendNotificationToDriverNow(
      String deviceRegistrationToken, String userRideRequestId, context) async {
    cloudMessagingServerToken = await getAccessToken();
    String endpointFirebaseCloudMessaging =
        "https://fcm.googleapis.com/v1/projects/pantherapp010-1b674/messages:send";
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cloudMessagingServerToken',
    };

    Map bodyNotification = {
      "body":
          "Destination Address: $destinationAddress", //Nội dung của thông báo, (địa chỉ đích đến)
      "title": "New Trip Request" //tiêu đề thông báo
    }; //chứa nội dung chính của thông báo hiển thị cho người dùng

    Map dataMap = {
      "click_action":
          "FLUTTER_NOTIFICATION_CLICK", //báo cho flutter xử lí việc nhấn vào thông báo
      "status": "done", //done
      "rideRequestId": userRideRequestId
    }; //dữ liệu tùy chỉnh đưuọc gửi kèm theo
    //Không hiển thị trực tiếp cho người dùng nhưng ứng dụng có thể sử dụng để thực hiện các hành
    //động cụ thể khi người dùng tương tác với thông báo

    Map<String, dynamic> officialNotificationFormat = {
      'message': {
        'token': deviceRegistrationToken,
        'notification': bodyNotification,
        'data': dataMap,
        //điều này đảm bảo gửi đến thiết bị nhanh nhất có thể
      }
    };

    var responseNotification = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: headerNotification,
      body: jsonEncode(
          officialNotificationFormat), // Use officialNoti here, not official
    );
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "pantherapp010-1b674",
      "private_key_id": "ba0ade13eab054fac5acc4dac4f42508ddfb3be9",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCnWLbzx3E4vERv\nNKOPtC+L2R90YjBGhcml0VT4An+egEFUYRJ5e9Xk/IyELsoLurtKOriGmzlhdAHj\n0uEPTh35wbTWc6JlS9qYWdTRd17RQQgAd05LnjLasXuXBeJQm8ZUvljUB7J5LaNJ\nxLG/aHjelA5U5DJ7NPZCsM+zyLG/4C48ODaHT6CI9Yq8JmlegP08kKLygi5O/Dhk\nHY635KxZlwu6D032DCC2yW9Z6lpGzSdDaHDC3A+qdS0HSVY5RCaBeKoRDRK3ZIBx\nVg+iaGkNGgfjyn1lDaoYpQ29PCM5MOsPe4luH7uSb/DrEn9BLN9Gwazeee+qEbzH\nHYCO92FjAgMBAAECggEAMCGugUAoWvKfVkLUFlVzZWw+BUnma6o4PMaQA0MotIxb\n/eprl2BcPV+8BJq2hxgenTN1dlW388UbdAznqXDE41xo6FNa7nqaNT6FHPgR3+qt\n5ABslwg5xTfN/bp2BMxBB4e14coS9ZKASAvYOd7RAOehlZ4KvPAXMkhLfQCoyzA2\nqT5kKhxzNxi86FkyVduhrm1HnEcl4fTAkbs/5SpVuLtbsqio6JpiR8CTSTAiEr0L\n4WKFThlVRN6PXghUDHWWZBMOvBZwnTdwMOYx1L+8q5I7+8xkjZrfOdGUcvu8Zt4R\ngJ//f3XkLByJjaKEXWMMnDBc9rP5nlib/jXBjDvKuQKBgQDbQv8CYStmNbDA3RQk\n1F5Og4B8sww/FOBkLJpDlYkIs9O0buvFGtOz6f6Dz/rLfMzuPj11cIdX6sPVQwwE\ngoD8xAUWsiS8X2bKHUXs/Jd205PJ3DU5bg0KTpAb6RyhYsEVkIhbPz1gleU3QDiF\ngHgmctguYjULYcitMHZT0LJ+ywKBgQDDYt8SqhM7tb2DKMu7H6bsN9MGxAfZcPRt\n7EnpM20uVOfqkYhMwzDxfK9/vaJKWRkkimNJfKexvIDjctZrbtPNWDJzBmVnhZpf\nks9c+SSikQCpvf6jQf/Kjd82qhRrbVoscoJtVimnva9aCFgLLcc5+3tAvn3/HxHo\n2bNJJ8b8yQKBgFHACfpmJltGe299Pkx5DexyJU7ZJyDB9OQEqUO3lk8zVSS6Epf7\n56D2Bpo4ykZicroFZL7LxPqnonp6NBneWp9jqo4Kv52oaFfFUFQK3aJFQp4Jx6Jx\nANWt8xck9DLL8jfLGrwCuSyw1rSh8jD8dE/JlAa/QQ3MWJkSL5wSfOq/AoGBAJTL\nVeBL3wvI0sLwrX4ak68usCll3ihsieiwWnUasdnn1RngrLDwsPQmpSwdyVrfUXNv\nZD9RjA+h43HTQZFdPDUUJo9MXqsgpriEACDop0qaLKwXwbSojVi/BC8IBTbudw6E\nQelsBZr1rHVfB1W0DhWM+4cJysAf9C6ko5FhlntpAoGAHciDZP6uiXLxQL7gtF/v\nkhyx3NcDXrC4xiHpH2H0UVUgr/Ki1OXKHSWEfluEi0+PpJUd1BoPHCkGxzCGdMuL\nCdQUIjXknt6p+fU9r3nf6E356Gs1RXd/s5A28Tj3s1f0fZPFy/OJaNaamA2u5+0s\nklYHh+yfmZiaiF85vAv1lYc=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "pantherflutter@pantherapp010-1b674.iam.gserviceaccount.com",
      "client_id": "109012225933935386239",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/pantherflutter%40pantherapp010-1b674.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

//get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();
    return credentials.accessToken.data;
  }

  static void readTripsKeyForOnlineUser(context) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection("Rides")
        .where('userId', isEqualTo: currentUser!.uid)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      int overAllTripsCounter = querySnapshot.docs.length;
      Provider.of<AppInfo>(context, listen: false)
          .updateOverAllTripsCounter(overAllTripsCounter);

      List<String> tripsKeysList = [];
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        tripsKeysList.add(querySnapshot.docs[i].id);
      }
      Provider.of<AppInfo>(context, listen: false)
          .updateOverAllTripsKeys(tripsKeysList);

      readTripsHistoryInformation(context);
    }
  }

  static void readTripsHistoryInformation(context) async {
    var tripsAllKeys =
        Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;
    for (int i = 0; i < tripsAllKeys.length; i++) {
      DocumentReference tripsRef =
          FirebaseFirestore.instance.collection("Rides").doc(tripsAllKeys[i]);
      tripsRef.get().then((value) {
        if (value.exists) {
          if ((value.data() as Map<String, dynamic>)["status"] == "ended") {
            TripsHistoryModel tripsHistoryModel =
                TripsHistoryModel.fromDocument(value);
            Provider.of<AppInfo>(context, listen: false)
                .updateOverAllTripsHistoryInformation(tripsHistoryModel);
          }
        }
      });
    }
  }
}
