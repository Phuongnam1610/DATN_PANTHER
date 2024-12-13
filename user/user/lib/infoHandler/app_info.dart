import 'package:flutter/cupertino.dart';
import 'package:user/models/direction_details_info.dart';
import 'package:user/models/directions.dart';
import 'package:user/models/trips_history_model.dart';

//là 1 provider quản lý cung câp thông tin về địa điểnm đón, trả khách và tổng số chuyến
//cho ứng dụng. ChangeNotifier để thông báo cho các widget khác khi có thay đổi dữ liệu
class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  DirectionDetailsInfo? tripDirectionDetailsInfo;
  int countTotalTrips = 0;

  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void updateTripDirectionDetailsInfo(DirectionDetailsInfo directionDetailsInfo) {
     tripDirectionDetailsInfo = directionDetailsInfo;
     notifyListeners();

  }

//cập nhật định vị địa chỉ điểm đón
  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

//cập nhật định vị địa chỉ điểm đến
  void updateDropOffLocationAddress(Directions? dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripsKeysList) {
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel tripsHistoryModel) {
    allTripsHistoryInformationList.add(tripsHistoryModel);
    notifyListeners();
  }
}
