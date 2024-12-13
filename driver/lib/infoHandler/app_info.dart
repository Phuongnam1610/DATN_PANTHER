import 'package:flutter/cupertino.dart';
import 'package:driver/models/directions.dart';

//là 1 provider quản lý cung câp thông tin về địa điểnm đón, trả khách và tổng số chuyến
//cho ứng dụng. ChangeNotifier để thông báo cho các widget khác khi có thay đổi dữ liệu
class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;

  int countTotalTrips = 0;

  //List<String> historyTripsKeysList = [];
  //List<TripsHistoryModel> allTripsHistoryInformationList = [];
//cập nhật định vị địa chỉ điểm đón
  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

//cập nhật định vị địa chỉ điểm đến
  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
