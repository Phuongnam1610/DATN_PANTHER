import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:driver/Assistants/assistant_request.dart';
import 'package:driver/global/global.dart';
import 'package:driver/global/map_key.dart';
import 'package:driver/infoHandler/app_info.dart';
import 'package:driver/models/direction_details_info.dart';
import 'package:driver/models/directions.dart';
import 'package:driver/models/user_model.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);
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

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.gomaps.pro/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$map_key";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    // if(responseDirectionApi == "Error Occurred, Failed. No Response") {
    //   return;
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi['routes'][0]['overview_polyline']['points'];

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

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();
    GeoCollectionReference(FirebaseFirestore.instance.collection('Users'))
        .delete(firebaseAuth.currentUser!.uid);
  }
}
