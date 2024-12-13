import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user/Assistants/assistant_methods.dart';
import 'package:user/Assistants/geofire_assistant.dart';
import 'package:user/global/global.dart';
import 'package:user/infoHandler/app_info.dart';
import 'package:user/models/active_nearby_available_driver.dart';
import 'package:user/screens/rate_driver_screen.dart';
import 'package:user/splashScreen/splash_screen.dart';
import 'package:user/widgets/pay_fare_amount_dialox.dart';

Future<void> _makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class BottomRequestingUi extends StatefulWidget {
  String selectedVehicleType = "";
  double? fareAmount;
  double? voucherFare;
  String? voucherCode;
  int? usedCount;
  String? distance_text;
  final Function(LatLng) upDateMarker;
  VoidCallback? onClose;

  BottomRequestingUi(
      {super.key,
      required this.selectedVehicleType,
      required this.upDateMarker,
      required this.voucherCode,
      required this.usedCount,
      required this.onClose,
      required this.fareAmount,
      required this.voucherFare,
      required this.distance_text});
  @override
  State<BottomRequestingUi> createState() => _BottomRequestingUiState();
}

class _BottomRequestingUiState extends State<BottomRequestingUi> {
  DocumentReference? referenceRideRequest; //id của chuyến đi đang được yêu cầu
  String userRideRequestStatus = "";
  String driverRideStatus = "Tài xế đang đến";
  String driverName = "";
  String driverPhone = "";
  String driverRatings = "";
  String driverCarDetails = "";
  String driverImage = "";
  // Position? userCurrentPosition;
  bool isDriverAssigned = false;
  StreamSubscription<DocumentSnapshot>? tripRidesRequestInfoStreamSubscription;
  StreamSubscription<DocumentSnapshot>? driverLocation;
  List<ActiveNearByAvailableDrivers> onlineNearByAvailableDriversList = [];
  bool requestPositionInfo = true;
  double searchLocationContainerHeight =
      220; //chiều cao hộp chức năng tìm kiếm địa chỉ
  double waitingResponsefromDriverContainerHeight =
      0; //hiển thị thông tin về việc đang chờ tài xế xác nhận yc đặt
  double assignedDriverInfoContainerHeight =
      0; //xác định chiều cao của container hiển thị thông tin tài xế đc phân công
  double suggestedRidesContainerHeight = 0;
  double searchingForDriverContainerHeight = 200;
  LatLng? driverCurrentPositionLat;

  saveRideRequestInformation(String vehicleType) async {
    var collection = FirebaseFirestore.instance.collection("Ride");
    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
    Map originLocationMap = {
      "latitude": originLocation!.locationLatitude,
      "longitude": originLocation.locationLongitude,
    };
    Map destinationLocationMap = {
      "latitude": destinationLocation!.locationLatitude,
      "longitude": destinationLocation.locationLongitude,
    };

    Map<String, dynamic> userInformationMap = {
      "customerId": currentUser!.uid,
      "pickupLocation": originLocationMap,
      "dropoffLocation": destinationLocationMap,
      "createdAt": DateTime.now(),
      "driverId": "waitting",
      // "customerName": userModelCurrentInfo!.name!,
      // "customerPhone": userModelCurrentInfo!.phoneNumber!,
      "pickupAddress": originLocation.locationName,
      "dropoffAddress": destinationLocation.locationName,
      "status": "requested",
      "fareAmount": widget.fareAmount,
      "voucherFare": widget.voucherFare,
      "distance": widget.distance_text,
    };
    referenceRideRequest = await collection.add(userInformationMap);
    tripRidesRequestInfoStreamSubscription = referenceRideRequest!
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        userRideRequestStatus = data['status'];

        if (data['driverId'] != 'waitting') {
          if (mounted) {
            setState(() {
              isDriverAssigned = true;
              streamOfListNearestActiveDrivers?.pause();
              if (driverLocation == null) {
                driverLocation = FirebaseFirestore.instance
                    .collection("User")
                    .doc(data['driverId'])
                    .snapshots()
                    .listen((event) async {
                  if (event.exists) {
                    Map<String, dynamic> driverData =
                        event.data() as Map<String, dynamic>;
                    if (driverData['location'] != null) {
                      driverCurrentPositionLat = LatLng(
                          AssistantMethods.geopointFrom(driverData).latitude,
                          AssistantMethods.geopointFrom(driverData).longitude);
                      widget.upDateMarker(driverCurrentPositionLat!);
                      if (userRideRequestStatus == 'accepted') {
                        updateArrivalTimeToUserPickupLocation(
                            driverCurrentPositionLat);
                                               QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('Voucher')
                            .where('code', isEqualTo: widget.voucherCode)
                            .limit(1)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          DocumentReference voucherRef = querySnapshot.docs.first.reference;
                          await voucherRef.update({"usedCount": FieldValue.increment(1)});
                        } else {
                          // Handle case where voucher code is not found.  For example:
                          print('Voucher code not found');
                          // Or show an error message to the user.
                        }
                      } else if (userRideRequestStatus == 'ontrip') {
                        updateReachingTimeToUsersDropOffLOcation(
                            driverCurrentPositionLat);
                      }
                    }
                  }
                });
              }
            });
          }
          var dataDriver = await FirebaseFirestore.instance
              .collection("User")
              .doc(data['driverId'])
              .get();
          var mapDataDriver = dataDriver.data() as Map<String, dynamic>;
          driverName = mapDataDriver['name'];
          driverPhone = mapDataDriver['phoneNumber'];
          driverImage = mapDataDriver['imageUrl'];
          driverRatings = mapDataDriver['rating'].toStringAsFixed(2);
          if (driverCurrentPositionLat != null) {
            // double driverCurrentPositionLat =
            //     (AssistantMethods.geopointFrom(mapDataDriver).latitude);
            // double driverCurrentPositionLng =
            //     (AssistantMethods.geopointFrom(mapDataDriver).longitude);
            // LatLng driverCurrentPositionLatlng =
            //     LatLng(driverCurrentPositionLat, driverCurrentPositionLng);
            //  widget.upDateMarker(driverCurrentPositionLatlng);

            //status =accepted
            // if (userRideRequestStatus == "accepted") {
            // updateArrivalTimeToUserPickupLocation(driverCurrentPositionLat);
            // }

//status = arrived
            if (userRideRequestStatus == "arrived") {
              setState(() {
                driverRideStatus = "Tài xế đã đến";
              });
            }

//status = ontrip
            // if (userRideRequestStatus == "ontrip") {
            //   updateReachingTimeToUsersDropOffLOcation(
            //       driverCurrentPositionLat);
            // }

            if (userRideRequestStatus == "ended") {
              if (data['fareAmount'] != null) {
                double fareAmount = double.parse(data['fareAmount'].toString());
                double voucherFare =
                    double.parse(data['voucherFare'].toString());
                var response = await showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        FareAmountCollectionDialog(
                          max(0, fareAmount! - voucherFare!),
                        ));
                if (response == "Cash Paid") {
                  //user can rate the driver now
                  if (data['driverId'] != null) {
                    String assignedDriverId = (data)['driverId'].toString();
                    String rideId = referenceRideRequest!.id;
                    await showDialog(
                        context: context,
                        builder: (c) => RateDriverScreen(
                            assignedDriverId: assignedDriverId,
                            rideId: rideId));
                    tripRidesRequestInfoStreamSubscription!.cancel();
                    driverLocation?.cancel();
                  }
                }
              }
            }
          }
        }
      } else {
        setState(() {
          isDriverAssigned = false;
        });
      }
    });

    onlineNearByAvailableDriversList =
        GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers(widget.selectedVehicleType);
  }

  updateArrivalTimeToUserPickupLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      //Biến này hoạt động như 1 cờ để ngăn chặn nhiều vị trí đồng thời

      requestPositionInfo =
          false; //ngăn các cuộc gọi khác đến hàm này cho đến khi hoàn thành cuộc gọi hiện tại
      //điều này ngăn chặn việc gửi nhiều yêu cầu đến api hướng dẫn và cập nhật trạng thái quá thường xuyên
      LatLng userPickupPosition = LatLng(userCurrentPosition!.latitude,
          userCurrentPosition!.longitude); //tạo 1 đối tượng latng
      //cho vị trí đón của người dùng

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
              driverCurrentPositionLatLng,
              userPickupPosition); //nếu tofont ại thông tin
      setState(() {
        //đặt là tài xế đang đến và hiển thị khoảng cách còn lại
        driverRideStatus =
            "Tài xế đang đến: ${directionDetailsInfo?.duration_text}";
      });

      requestPositionInfo = true; //cho phép các cuộc gọi tiếp theo đến hàm này
    }
  }

  updateReachingTimeToUsersDropOffLOcation(driverCurrentPositionLatlng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;

      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
        dropOffLocation!.locationLatitude!,
        dropOffLocation.locationLongitude!,
      );

      var directionDetailsInfo =
          await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatlng,
        userDestinationPosition,
      );
      setState(() {
        driverRideStatus =
            "Thời gian đến điểm đến: ${directionDetailsInfo?.duration_text}";
      });

      requestPositionInfo = true;
    }
  }

  //tìm kiếm các tài xế gần nhất đang online
  //theo loại xe được chọn
  searchNearestOnlineDrivers(String selectedVehicleType) async {
    //nếu danh sách tài xế đang trực tuyến bằng 0
    //thực hiện hủy chuyến
    if (onlineNearByAvailableDriversList.isEmpty) {
      //cancel/ delete the rideRequest information
      referenceRideRequest!.delete(); //xóa thông tin đặt xe

      // setState(() {
      //   polylineSet.clear(); //đặt lại giao diện// xóa đường vẽ
      //   markersSet.clear(); //xóa maker
      //   circlesSet.clear(); //xóa circlexet
      //   pLineCoordinatedList.clear(); //xóa danh sách tọa độ
      // });

      Fluttertoast.showToast(
          msg: "Không có tài xế nào gần bạn"); //không tìm thấy tài xế
      Fluttertoast.showToast(
          msg: "Đang tìm kiếm lại"); //thực hiện khởi động lại app
      //Chờ 4s khởi động lại
      Future.delayed(Duration(milliseconds: 4000), () {
        referenceRideRequest!.delete(); //xóa lần nữa đảm bảo xóa thành công
        if(mounted){
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => SplashScreen()));}
      }); // Future.delayed
      return;
    } //nếu khác 0 lấy ra danh sách thông tin tài xế đang online
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
    print("Danh sách tài xế online: $driversList");
    //lọc danh sách các tài xế đang online gần, nếu loại phương tiện trùng với phương tiện đã chọn
    //thì gửi thông báo cho tài xế đó
    for (int i = 0; i < driversList.length; i++) {
      if (driversList[i]['car_details']["vehicleTypeId"] ==
          selectedVehicleType) {
        AssistantMethods.sendNotificationToDriverNow(
            driversList[i]["token"], referenceRideRequest!.id, context);
      }
    }
    Fluttertoast.showToast(msg: "Gửi thông báo thành công");
    // showSearchingForDriversContainer();

    // FirebaseFirestore.instance
    //     .collection("Ride")
    //     .doc(referenceRideRequest!.id)
    //     .snapshots()
    //     .listen((snapshot) {
    //   if (snapshot.exists) {
    //     var data = snapshot.data() as Map<String, dynamic>;
    //     if (data['driverId'] != 'waitting') {

    //       // showUIForAssignedDriverInfo();
    //       // String assignedDriverId = (data)['driverId'].toString();
    //       //Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen()));
    //       // referenceRideRequest.;
    //       // tripRidesRequestInfoStreamSubscription!.cancel();
    // }
    // }
    // });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    driversList.clear();
    CollectionReference referenceDrivers =
        FirebaseFirestore.instance.collection("User");
    CollectionReference referenceVehicles =
        FirebaseFirestore.instance.collection("Vehicle");
    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await referenceDrivers
          .doc(onlineNearestDriversList[i].driverId.toString())
          .get()
          .then((value) async {
        var driverKeyInfo = value.data()! as Map<String, dynamic>;
        var vehicleData =
            await referenceVehicles.doc(driverKeyInfo["vehicleOnId"]).get();
        var vehicle = (vehicleData.data()! as Map<String, dynamic>);
        driverKeyInfo["car_details"] = vehicle;
        driversList.add(driverKeyInfo);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    saveRideRequestInformation(widget.selectedVehicleType);
  }

  @override
  void dispose() {
    tripRidesRequestInfoStreamSubscription!.cancel();
    super.dispose();
  }

  //hàm lưu thông tin đặt xe vào firebase

  @override
  Widget build(BuildContext context) {
    String formatVND(double amount) {
      final format = NumberFormat.simpleCurrency(
          locale: 'vi',
          decimalDigits:
              0); // decimalDigits: 0 để không hiển thị phần thập phân
      return format.format(amount);
    }

    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: darkTheme ? Colors.black : Colors.white,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        // BorderRadius.only
      ),
      // BoxDecoration
      child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDriverAssigned)
                  Container(
                    decoration: BoxDecoration(
                      color: darkTheme ? Colors.black : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearProgressIndicator(
                            color:
                                darkTheme ? Colors.amber.shade400 : Colors.blue,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              "Đang tìm tài xế...",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ), // TextStyle
                            ), // Text
                          ), // Center
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              referenceRideRequest!.delete();
                              widget.onClose!.call();
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: darkTheme ? Colors.black : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                              ), // BoxDecoration
                              child: Icon(Icons.close, size: 25),
                            ), // Container
                          ), // GestureDetector
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Hủy",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                if (isDriverAssigned)
                  Container(
                    decoration: BoxDecoration(
                      color: darkTheme ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ), // BoxDecoration
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            driverRideStatus,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: 5),
                          Divider(
                            thickness: 1,
                            color: darkTheme ? Colors.grey : Colors.grey[300],
                          ),
                          Text(
                            "Thông tin tài xế",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    // Replaced with CircleAvatar for driver image
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        driverImage), // Assuming driverImage is a URL
                                    backgroundColor: Colors.grey[
                                        200], // Default background color if image fails to load
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        driverName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors
                                                .orange, // Corrected color name
                                          ),
                                          Text(driverRatings,
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Image.asset("images/car.png", scale: 3),
                                  Text(driverCarDetails,
                                      style: TextStyle(fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          Divider(
                            thickness: 1,
                            color: darkTheme ? Colors.grey : Colors.grey[300],
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _makePhoneCall("tel: $driverPhone");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.blue,
                            ),
                            icon: Icon(Icons.phone),
                            label: Text("Gọi tài xế"),
                          ), // ElevatedButton.icon
                        ],
                      ),
                    ), // Padding
                  )
              ])),
    );
  }
}
