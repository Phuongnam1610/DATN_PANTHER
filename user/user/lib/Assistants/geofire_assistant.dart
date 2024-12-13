import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/models/active_nearby_available_driver.dart';

class GeoFireAssistant {

  static List<ActiveNearByAvailableDrivers> activeNearbyAvailableDriversList =
      [];

  static void deleteOfflineDriverFromList(String driverId) {
    int IndexNumber = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId == driverId);
    activeNearbyAvailableDriversList.removeAt(IndexNumber);
  }

  static void updateActiveNearbyAvailableDriverLocation(
      ActiveNearByAvailableDrivers driverWhoMove) {
    int IndexNumber = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId == driverWhoMove.driverId);

    activeNearbyAvailableDriversList[IndexNumber].locationLatitude =
        driverWhoMove.locationLatitude;
    activeNearbyAvailableDriversList[IndexNumber].locationLongitude =
        driverWhoMove.locationLongitude;
  }
}
