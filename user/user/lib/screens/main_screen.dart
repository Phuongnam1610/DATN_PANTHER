import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:user/Assistants/assistant_methods.dart';
import 'package:user/Assistants/geofire_assistant.dart';
import 'package:user/global/global.dart';
import 'package:user/infoHandler/app_info.dart';
import 'package:user/models/active_nearby_available_driver.dart';
import 'package:user/screens/drawer_screen.dart';
import 'package:user/screens/search_places_screen.dart';
import 'package:user/widgets/bottom_requesting_ui.dart';
import 'package:user/widgets/bottom_suggest_ui.dart';
import 'package:user/widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng?
      pickLocation; // kiểu dữ liệu biểu thị tọa độ địa lý 1 điểm trên bản đồ (vĩ độ, kinh độ)
  //dùng để lưu tọa độ người dùng chọn làm điểm đến, có thể null
  loc.Location location =
      loc.Location(); //cho phép app truy cập vào dịch vụ xác định vị trí
//địa chị dạng văn bản
  double fareAmount = 0;
  double voucherFare = 0;
  String distance = "";
  String voucherCode = "";
  int usedCount = 0;
  final Completer<GoogleMapController> _contorllerGoogleMap = Completer();
  //quả lý việc tạo và cung cấp điều khiển GoogleMapController
  //tuowntg tác với bản đồ GoogleMap
  GoogleMapController? newGoogleMapController;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.0857496559143),
    zoom: 14.4746,
  );
//biểu diễn vị trí và điều khiển camera, đưuọc dùng để đặt vị trí và zoom
//ban đầu cho khi ứng dụng khởi chạy( tọa dộ trên là trụ sở gg)
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
//khóa này cho phép truy cập vào ScaffoldState nền tảng ứng dụng
//_scaffoldState được dùng để thao tác với Scaffold như hiển thị Snackbar
//thông báo ngắn hoặc điều khiển AppBar
  double searchLocationContainerHeight =
      220; //chiều cao hộp chức năng tìm kiếm địa chỉ
  double waitingResponsefromDriverContainerHeight =
      0; //hiển thị thông tin về việc đang chờ tài xế xác nhận yc đặt
  double assignedDriverInfoContainerHeight =
      0; //xác định chiều cao của container hiển thị thông tin tài xế đc phân công
  double suggestedRidesContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;
  // Position? userCurrentPosition;
  var geolocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatedList = []; //vẽ 1 đường đa tuyến
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  bool openNavigationDrawer = true;

  BitmapDescriptor?
      activeNearbyIcon; //lưu trữ 1 biểu tượng icon được dùng để hiển thị trên bản đồ
  String selectedVehicleType = "";
  bool requestPositionInfo = true;
  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); //lay ra toa do hien tai
    userCurrentPosition = cPosition; //gan toa do nguoi dung hien tai vao global
    LatLng latlngPosition = LatLng(userCurrentPosition!.latitude,
        userCurrentPosition!.longitude); //chuyen ve toa do latng
    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition, zoom: 15); //tao 1 goc nhin
    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(
        cameraPosition)); //cap nhat camera ve nguoi dung hien tai
    await AssistantMethods.searchAddressFromCoordinates(
        userCurrentPosition!, context);

    initializeGeoFireListener();
    // AssistantMethods.readTripsKeyForOnlineUser(context);
  }

  initializeGeoFireListener() async {
    final GeoFirePoint center = GeoFirePoint(GeoPoint(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude));
    const double radius = 30;
    const String field = "location";
    final CollectionReference<Map<String, dynamic>> collectionReference =
        FirebaseFirestore.instance.collection('User');

    GeoPoint geopointFrom(Map<String, dynamic> data) {
      return (data['location'] as Map<String, dynamic>)['geopoint'] as GeoPoint;
    }

    streamOfListNearestActiveDrivers =
        GeoCollectionReference<Map<String, dynamic>>(collectionReference)
            .subscribeWithin(
      center: center,
      radiusInKm: radius,
      field: field,
      geopointFrom: geopointFrom,
    )
            .listen((map) {
      GeoFireAssistant.activeNearbyAvailableDriversList.clear();

      for (var doc in map) {
        // if (GeoFireAssistant.activeNearbyAvailableDriversList
        //     .any((element) => element.driverId == doc.data()!['userId'])) {
        //   // Xóa tài xế khỏi danh sách
        //   GeoFireAssistant.activeNearbyAvailableDriversList.removeWhere(
        //     (element) => element.driverId == doc.data()!['userId'],
        //   );
        // }

        if (doc.data()!['status'] == 'online') {
          GeoFireAssistant.activeNearbyAvailableDriversList.add(
              ActiveNearByAvailableDrivers.fromDocumentSnapshot(doc.data()!));
        } else {}
        displayActiveDriversOnUsersMap();
        if(mounted){
        setState(() {});}
      }
    });
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
      );
      BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        'images/car.png',
      ).then((value) {
        activeNearbyIcon = value;
      });
    }
  }

  displayActiveDriversOnUsersMap() {
    if(mounted){
    setState(() {
      // markersSet.clear();
      // circlesSet.clear();
      markersSet.removeWhere((marker) => marker.markerId.value.startsWith(
          'driver_')); // Xóa tất cả các marker tài xế hiện có trên bản đồ

      for (ActiveNearByAvailableDrivers eachDriver
          in GeoFireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver_" + eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        ); // Marker

        // driversMarkerSet.add(marker);
        markersSet.removeWhere((existingMarker) =>
            existingMarker.markerId.value == eachDriver.driverId);
        markersSet.add(marker);
      }

      setState(() {
        // markersSet = driversMarkerSet;
      });
    });
  }}

  Future<void> drawPolylineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: "Vui lòng đợi..."),
    );

    var directionDetailsInfo =
        Provider.of<AppInfo>(context, listen: false).tripDirectionDetailsInfo;
    Navigator.pop(context);
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCoordinatedList.clear();

    if (decodePolylinePointsResultList.isNotEmpty) {
      for (var pointlatlng in decodePolylinePointsResultList) {
        pLineCoordinatedList
            .add(LatLng(pointlatlng.latitude, pointlatlng.longitude));
      }
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatedList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      ); // LatLngBounds
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      ); // LatLngBounds
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId('originID'),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ); // Marker
    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationID'),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ); // Marker

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId('originID'),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    ); // Circle

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  //tìm kiếm các tài xế gần nhất đang online
  //theo loại xe được chọn

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    driversList.clear();
    CollectionReference referenceDrivers =
        FirebaseFirestore.instance.collection("User");
    CollectionReference referenceVehicles =
        FirebaseFirestore.instance.collection("Vehicles");
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
        print("driver key information =$driverKeyInfo");
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  @override
  void dispose() {
    super.dispose();
    streamOfListNearestActiveDrivers!.cancel();
  }

  bool _showBottomSheet = false;
  bool _showBottomRequest = false;

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    String pickUpName = Provider.of<AppInfo>(context).userPickUpLocation != null
        ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!)
        : "Không xác định địa chỉ";
    String truncatedPickUp = pickUpName.length > 50
        ? pickUpName.substring(0, 40) + "..."
        : pickUpName;
    String dropOffName =
        Provider.of<AppInfo>(context).userDropOffLocation != null
            ? (Provider.of<AppInfo>(context).userDropOffLocation!.locationName!)
            : "Không xác định địa chỉ";
    String truncatedDropOff = dropOffName.length > 50
        ? dropOffName.substring(0, 40) + "..."
        : dropOffName;
    createActiveNearByDriverIconMarker();
    return GestureDetector(
        onTap: () {},
        child: Scaffold(
            key: _scaffoldState,
            drawer: DrawerScreen(),
            body: Stack(children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: _kGooglePlex,
                polylines: polylineSet,
                markers: markersSet,
                circles: circlesSet,
                onMapCreated: (GoogleMapController controller) {
                  _contorllerGoogleMap.complete(controller);
                  newGoogleMapController = controller;
                  setState(() {
                    bottomPaddingOfMap = 200;
                  });
                  locateUserPosition();
                },
                // onCameraMove: (CameraPosition? position) {
                //   if (pickLocation != position!.target) {
                //     setState(() {
                //       pickLocation = position.target;
                //     });
                //   }
                // },
                // onCameraIdle: () {
                //   getAddressFromLatlng();
                // }, //trạng thái nghỉ
              ),
              // Align(
              //     alignment: Alignment.center,
              //     child: Padding(
              //       padding: const EdgeInsets.only(bottom: bottomPaddingOfMap),
              //       child: Image.asset(
              //         "images/pick.png",
              //         height: 45,
              //         width: 45,
              //       ),
              //     )),

              // custom headburger button for drawer
              Positioned(
                top: 50,
                left: 20,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      _scaffoldState.currentState!.openDrawer();
                    },
                    child: CircleAvatar(
                      backgroundColor:
                          darkTheme ? Colors.amber.shade400 : Colors.white,
                      child: Icon(
                        Icons.menu,
                        color: darkTheme ? Colors.black : Colors.lightBlue,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: darkTheme ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ), // BoxDecoration
                          child: Column(children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ), // BoxDecoration
                                child: Column(children: [
                                  Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: darkTheme
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Từ",
                                                style: TextStyle(
                                                  color: darkTheme
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                  // Provider.of<AppInfo>(context)
                                                  //             .userPickUpLocation !=
                                                  //         null
                                                  //     ? (Provider.of<AppInfo>(
                                                  //             context)
                                                  //         .userPickUpLocation!
                                                  //         .locationName!)
                                                  //     : "Không xác định địa chỉ",
                                                  truncatedPickUp,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14))
                                            ],
                                          )
                                        ],
                                      )),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 2,
                                    color:
                                        darkTheme ? Colors.white : Colors.black,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(5),
                                      child: GestureDetector(
                                          onTap: () async {
                                            //chuyển đến mnaf hình searchplace
                                            //await đoạn mã sẽ đợi cho đến khi navigator.push trả về kết quả
                                            //trước khi tiếp tục thực thi
                                            //ứng dụng sẽ đợi người dùng hoàn thành việc tìm kiếm địa điểm trên
                                            //SearchPlacecsScreen
                                            var responseFromSearchScreen =
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SearchPlacesScreen()));
                                            //Nếu kết quả trả về là obtainedDropoff đại diện cho việc
                                            //người dùng đã chọn 1 điểm đến trên màn hình tìm kiếm
                                            if (responseFromSearchScreen ==
                                                "obtainedDropoff") {
                                              //hàm setState đưuọc gọi để cập nhật trajg thái của widget
                                              //Nó sẽ đóng ngăn điều hướng NavigationDrawer
                                              setState(() {
                                                openNavigationDrawer = false;
                                              });
                                              await drawPolylineFromOriginToDestination(
                                                  darkTheme);
                                            }
                                          },
                                          child: Row(children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: darkTheme
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Đến",
                                                    style: TextStyle(
                                                      color: darkTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      // Provider.of<AppInfo>(
                                                      //                 context)
                                                      //             .userDropOffLocation !=
                                                      //         null
                                                      //     ? (Provider.of<
                                                      //                 AppInfo>(
                                                      //             context)
                                                      //         .userDropOffLocation!
                                                      //         .locationName!)
                                                      //     : "Đi đâu?",
                                                      //
                                                      truncatedDropOff,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14))
                                                ])
                                          ]))),
                                ])),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ElevatedButton(
                                //   onPressed: () async {
                                //         var responseFromSearchScreen =
                                //                 await Navigator.push(
                                //                     context,
                                //                     MaterialPageRoute(
                                //                         builder: (context) =>
                                //                             SearchPlacesScreen()));
                                //         if (responseFromSearchScreen ==
                                //                 "obtainedDropoff") {
                                //               //hàm setState đưuọc gọi để cập nhật trajg thái của widget
                                //               //Nó sẽ đóng ngăn điều hướng NavigationDrawer
                                //               setState(() {
                                //                 openNavigationDrawer = false;
                                //               });
                                //               await drawPolylineFromOriginToDestination(
                                //                   darkTheme);
                                //             }
                                //   },
                                //   child: Text(
                                //     'Chọn chính xác',
                                //     style: TextStyle(
                                //       color: darkTheme
                                //           ? Colors.black
                                //           : Colors.white,
                                //     ),
                                //   ),
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: darkTheme
                                //         ? Colors.amber.shade400
                                //         : Colors.blue,
                                //     textStyle: TextStyle(
                                //       fontWeight: FontWeight.bold,
                                //       fontSize: 16,
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Provider.of<AppInfo>(context,
                                    //         listen: false)
                                    //     .userDropOffLocation !=
                                    if (Provider.of<AppInfo>(context,
                                                listen: false)
                                            .userDropOffLocation !=
                                        null) {
                                      setState(() {
                                        _showBottomSheet = true;
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Vui lòng chọn điểm đến");
                                    }
                                  },
                                  child: Text(
                                    "Báo giá",
                                    style: TextStyle(
                                      color: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                    ), // TextStyle
                                  ),
                                ),
                              ],
                            ),
                          ]))
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showBottomSheet
                        ? Consumer<AppInfo>(
                            builder: (context, appInfo, child) => MyBottomSheet(
                              onClose: () {
                                setState(() {
                                  selectedVehicleType = "";
                                  _showBottomSheet = false;
                                });
                              },
                              onRideRequest: (selectedVehicleType, fare, vFare,
                                  distance, voucherCode, usedCount) {
                                setState(() {
                                  _showBottomSheet = false;
                                  _showBottomRequest = true;
                                  this.selectedVehicleType =selectedVehicleType;
                                  fareAmount = fare;
                                  voucherFare = vFare;
                                  this.distance = distance;
                                  this.voucherCode = voucherCode;
                                  this.usedCount = usedCount;
                                });
                              },
                            ),
                          )
                        : SizedBox.shrink()),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showBottomRequest
                        ? Consumer<AppInfo>(
                            builder: (context, appInfo, child) =>
                                BottomRequestingUi(
                              selectedVehicleType: selectedVehicleType,
                              fareAmount: fareAmount,
                              voucherFare: voucherFare,
                              distance_text: distance,
                              voucherCode: voucherCode,
                              usedCount: usedCount,
                              onClose: (() {
                                setState(() {
                                  _showBottomRequest = false;
                                });
                              }),
                              upDateMarker: ((position) {
                                markersSet.removeWhere((marker) =>
                                    marker.markerId.value.startsWith(
                                        'driver_')); // Xóa tất cả các marker tài xế hiện có trên bản đồ
                                Marker marker = Marker(
                                  markerId: MarkerId("driver_ride"),
                                  position: position,
                                  icon: activeNearbyIcon!,
                                  rotation: 360,
                                );
                                setState(() {
                                  markersSet.add(marker);
                                });
                              }),
                            ),
                          )
                        : SizedBox.shrink()),
              ), //UI for displaying assigned driver information
            ])));
  }
}
