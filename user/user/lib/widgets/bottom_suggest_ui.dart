import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:user/Assistants/assistant_methods.dart';
import 'package:user/global/global.dart';
import 'package:user/infoHandler/app_info.dart';
import 'package:user/models/direction_details_info.dart';
import 'package:user/widgets/bottom_requesting_ui.dart';

class MyBottomSheet extends StatefulWidget {
  final VoidCallback? onClose;
  final Function(String, double, double, String,String,int) onRideRequest;

  MyBottomSheet({super.key, this.onClose, required this.onRideRequest});
  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  double? fareCar;
  String selectedVehicleType = "";
  DocumentReference? referenceRideRequest; //id của chuyến đi đang được yêu cầu
  StreamSubscription<DocumentSnapshot>? tripRidesRequestInfoStreamSubscription;
  String userRideRequestStatus = "";
  String driverRideStatus = "Driver is coming";
  String voucherCode = "";
  int usedCount=0;
  double? fareXe;
  double? voucherFare = 0;
  double? voucherFareCar=0;
  double? voucherFareXe=0;
  String? distance_text;
  Future<void> _getFareAmount() async {
    var directionDetailsInfo =
        Provider.of<AppInfo>(context, listen: false).tripDirectionDetailsInfo;
    fareCar = await AssistantMethods.calculateFareAmountFromOriginToDestination(
        directionDetailsInfo!, "oto");
    fareXe = await AssistantMethods.calculateFareAmountFromOriginToDestination(
        directionDetailsInfo!, "xemay");
    distance_text = directionDetailsInfo!.distance_text;
    setState(() {});
  }

  @override
  void initState()  {
    super.initState();
    if (Provider.of<AppInfo>(context, listen: false).tripDirectionDetailsInfo !=
        null) {
      _getFareAmount();
    }
  }

  bool isVoucherApplied = false; // Add a flag to track voucher application

  @override
  Widget build(BuildContext context) {
    // _getFareAmount();
    String formatVND(double amount) {
      final format = NumberFormat.simpleCurrency(
          locale: 'vi',
          decimalDigits:
              0); // decimalDigits: 0 để không hiển thị phần thập phân
      return format.format(amount);
    }

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
            Container(
              child: Row(
                children: [
                  Image.asset(
                    "images/origin.png",
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    truncatedPickUp,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  child: Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10), // Container
                      Text(
                        truncatedDropOff,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            
            Text(
"Khoảng cách ${distance_text ?? ''}"      , 
       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Đề xuất",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicleType = "oto";
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedVehicleType == "oto"
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ), // Box Decoration
                    child: Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          Image.asset(
                            "images/ca.png",
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Car",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedVehicleType == "oto"
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            fareCar != null
                                ? formatVND(max(0, (fareCar! - voucherFareCar!)))
                                : "Calculating...", // Display calculated fare or "Calculating..."
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          )
                        ],
                        // Column
                      ), // Padding
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVehicleType = "xemay";
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedVehicleType == "xemay"
                          ? Colors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ), // Box Decoration
                    child: Padding(
                      padding: EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          Image.asset(
                            "images/cng.png",
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Xe máy",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedVehicleType == "xemay"
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            fareXe != null
                                ? formatVND((max(0, fareXe! - voucherFareXe!)))
                                : "Calculating...", // Display calculated fare or "Calculating..."
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          )
                        ],
                        // Column
                      ), // Padding
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 10,
            ),
            TextField(
              enabled: !isVoucherApplied, // Disable if voucher is applied
              onChanged: (value) {
                if (!isVoucherApplied) {
                  // Only update if not applied
                  voucherCode = value;
                }
              },
              decoration: InputDecoration(
                hintText: 'Mã giảm giá',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                if (voucherCode.isEmpty) {
                  Fluttertoast.showToast(msg: "Vui lòng nhập mã giảm giá");
                  return;
                }
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                  .collection('Voucher')
                  .where('code', isEqualTo: voucherCode)
                  .limit(1) // Limit to 1 result since voucher codes should be unique
                  .get();
                if (querySnapshot.docs.isNotEmpty) {
                  var codeData = querySnapshot.docs.first.data() as Map<String, dynamic>;

                  int usageLimit = codeData["usageLimit"] as int;
                  usedCount = codeData["usedCount"] as int;
                  if (usedCount < usageLimit) {
                    //kiểm tra ngày hết hạn
                    DateTime validFrom = codeData["validFrom"].toDate();
                    DateTime validUntil =
                        codeData["validUntil"].toDate();
                    DateTime current = DateTime.now();
                    if (current.isAfter(validFrom) &&
                        current.isBefore(validUntil)) {
                      //kiểm tra số tiền giảm giá
                      double discountValue =
                          codeData["discountValue"].toDouble();
                      String discountType =
                          codeData["discountType"] as String;
                      setState(() {
                        if (discountType == "fixed") {
                          voucherFareCar= discountValue;
                          voucherFareXe=discountValue;
                        } else {
                          voucherFareCar= (fareCar! * discountValue) / 100.0;
                          voucherFareXe= (fareXe! * discountValue) / 100.0;
                        }
                      });
                      // //cập nhật số lần sử dụng
                      // usedCount++ ;
                      // await FirebaseFirestore.instance.collection("Voucher").doc(voucherCode).update({"usedCount":usedCount}) ;

                      setState(() {
                        isVoucherApplied = true;
                      });

                      Fluttertoast.showToast(
                          msg: "Áp dụng mã giảm giá thành công!");
                    } else {
                      Fluttertoast.showToast(
                          msg: "Mã giảm giá đã hết lượt sử dụng!");
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: "Mã giảm giá đã hết lượt sử dụng!");
                  }
                } else {
                  Fluttertoast.showToast(msg: "Mã giảm giá không tồn tại!");
                }
              },
              child: Text('Áp dụng'),
            ),

            SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                if (selectedVehicleType != "") {
                  var fare = selectedVehicleType == "oto" ? fareCar : fareXe;
                  voucherFare=selectedVehicleType == "oto" ? voucherFareCar : voucherFareXe;
                  widget.onRideRequest!.call(
                      selectedVehicleType, fare!, voucherFare!, distance_text!,voucherCode,usedCount);
                  // showModalBottomSheet(
                  //     context: context,
                  //     isScrollControlled: true,
                  //     builder: (_) => BottomRequestingUi(
                  //         selectedVehicleType: selectedVehicleType));
                } else {
                  Fluttertoast.showToast(msg: "Vui lòng chọn phương tiện");
                }
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ), // BoxDecoration
                child: Center(
                  child: Text(
                    "Tìm tài xế",
                    style: TextStyle(
                      color: darkTheme ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ), // TextStyle
                  ), // Text
                ), // Center
              ), // Container
            ), // GestureDetector
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                widget.onClose?.call();
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(10),
                ), // BoxDecoration
                child: Center(
                  child: Text(
                    "Hủy",
                    style: TextStyle(
                      color: darkTheme ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ), // TextStyle
                  ), // Text
                ), // Center
              ), // Container
            ), // GestureDetector
          ],
        ),
      ),
    );
  }
}
