import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveNearByAvailableDrivers {
  String? driverId;
  double? locationLatitude;
  double? locationLongitude;

  ActiveNearByAvailableDrivers({
    this.driverId,
    this.locationLatitude,
    this.locationLongitude,
  });
  static GeoPoint geopointFrom(Map<String, dynamic> data) {
    return (data['location'] as Map<String, dynamic>)['geopoint'] as GeoPoint;
  }

  factory ActiveNearByAvailableDrivers.fromDocumentSnapshot(
      Map<String, dynamic> doc) {
    return ActiveNearByAvailableDrivers(
      driverId: doc['userId'] as String,
      locationLatitude: geopointFrom(doc).latitude,
      locationLongitude: geopointFrom(doc).longitude,
    );
  }
}
