import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:user/Assistants/assistant_methods.dart';
import 'package:user/global/map_key.dart';
import 'package:user/infoHandler/app_info.dart';
import 'package:user/models/direction_details_info.dart';
import 'package:user/models/directions.dart';

class PrecisePickUpScreen extends StatefulWidget {
  const PrecisePickUpScreen({super.key});

  @override
  State<PrecisePickUpScreen> createState() => _PrecisePickUpScreenState();
}

class _PrecisePickUpScreenState extends State<PrecisePickUpScreen> {
  LatLng?
      pickLocation; // kiểu dữ liệu biểu thị tọa độ địa lý 1 điểm trên bản đồ (vĩ độ, kinh độ)
  //dùng để lưu tọa độ người dùng chọn làm điểm đến, có thể null
  loc.Location location =
      loc.Location(); //cho phép app truy cập vào dịch vụ xác định vị trí
  // String? _address; //địa chị dạng văn bản

  final Completer<GoogleMapController> _contorllerGoogleMap = Completer();
  //quả lý việc tạo và cung cấp điều khiển GoogleMapController
  //tuowntg tác với bản đồ GoogleMap
  GoogleMapController? newGoogleMapController;
  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
// CameraPosition

  // locateUserPosition() async {
  //   Position cPosition = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  //   userCurrentPosition = cPosition;
  //   LatLng latlngPosition =
  //       LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
  //   CameraPosition cameraPosition =
  //       CameraPosition(target: latlngPosition, zoom: 15);
  //   newGoogleMapController!
  //       .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

  //   String humanReadableAddress =
  //       await AssistantMethods.searchAddressFromCoordinates(
  //           userCurrentPosition!, context);
  // }
// getAddressFromLatlng() async {
//     try {
//       GeoData data = await Geocoder2.getDataFromCoordinates(
//           latitude: pickLocation!.latitude,
//           longitude: pickLocation!.longitude,
//           googleMapApiKey: map_key);
//       setState(() {
//         Directions userDropOffLocation = Directions();
//         userDropOffLocation.locationLatitude = pickLocation!.latitude;
//         userDropOffLocation.locationLongitude = pickLocation!.longitude;
//         userDropOffLocation.locationName = data.address;
//         Provider.of<AppInfo>(context, listen: false)
//             .updatePickUpLocationAddress(userDropOffLocation);
//         // _address = data.address;
//       });
//     } catch (e) {}
//   }
  locateUserPosition() async {
    // Position cPosition = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // userCurrentPosition = cPosition;
    var dropOffLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
    LatLng latlngPosition = LatLng(
        dropOffLocation!.locationLatitude!, dropOffLocation.locationLongitude!);
    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition, zoom: 15);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  getAddressFromLatlng() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: pickLocation!.latitude,
          longitude: pickLocation!.longitude,
          googleMapApiKey: map_key);
       
            var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    // var destinationPosition =
    //     Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(pickLocation!.latitude!,
        pickLocation!.longitude);
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);
    if(directionDetailsInfo != null) {
       Directions userDropOffLocation = Directions();
        userDropOffLocation.locationLatitude = pickLocation!.latitude;
        userDropOffLocation.locationLongitude = pickLocation!.longitude;
        userDropOffLocation.locationName = data.address;
        Provider.of<AppInfo>(context, listen: false)
            .updateDropOffLocationAddress(userDropOffLocation);
        Provider.of<AppInfo>(context, listen: false)
            .updateTripDirectionDetailsInfo(directionDetailsInfo);
    }
    else{
      Provider.of<AppInfo>(context, listen: false)
            .updateDropOffLocationAddress(null);
        
    }

 
    } catch (e) {
    print('Unknown error getting address: $e');
    }
  }

//biểu diễn vị trí và điều khiển camera, đưuọc dùng để đặt vị trí và zoom
//ban đầu cho khi ứng dụng khởi chạy( tọa dộ trên là trụ sở gg)
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,

            onMapCreated: (GoogleMapController controller) {
              _contorllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 50;
              });
              locateUserPosition();
            },
            onCameraMove: (CameraPosition? position) {
              //Khi camera di chuyển, lấy ra tọa độ được chọn là tọa độ chính giữa
              if (pickLocation != position!.target) {
                // setState(() {
                  pickLocation = position.target;
                // });
              }
            },
            onCameraIdle: () {
              getAddressFromLatlng();
            }, //trạng thái nghỉ
          ),
          Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: 60, bottom: bottomPaddingOfMap),
                child: Image.asset(
                  "images/pick.png",
                  height: 45,
                  width: 45,
                ),
              )),
          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ), // BoxDecoration
              padding: EdgeInsets.all(20),
              child: Text(
                Provider.of<AppInfo>(context).userDropOffLocation != null
                    ? (Provider.of<AppInfo>(context)
                        .userDropOffLocation!
                        .locationName!)
                    : "Không xác định địa chỉ",
                overflow: TextOverflow.visible,
                softWrap: true,
              ), // Text
            ), // Container
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children:[
                  ElevatedButton(
                  onPressed: () {
                    if(Provider.of<AppInfo>(context, listen:false).tripDirectionDetailsInfo != null){
                    Navigator.pop(context, "obtainedDropoff");}
                    else{
                       Fluttertoast.showToast(msg: "Vui lòng chọn địa chỉ trước khi tiếp tục");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        darkTheme ? Colors.amber.shade400 : Colors.blue,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ), // TextStyle
                  child: Text('Chọn vị trí này'),
                ),
                ElevatedButton(
                  onPressed: () {
                  Provider.of<AppInfo>(context,listen:false).updateDropOffLocationAddress(null);
                    Navigator.pop(context, "cancelDropOff");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        darkTheme ? Colors.amber.shade400 : Colors.blue,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ), // TextStyle
                  child: Text('Hủy'),
                ),
                ] 
              ), // ElevatedButton
            ), // Padding
          ), // Positioned

// Positioned
        ],
      ),
      // Scaffold
    );
  }
}
