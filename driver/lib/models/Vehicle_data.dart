import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleData {
  String? vehicleId;
  String? driverId;
  String? make;
  String? model;
  String? licensePlate;
  int? capacity;
  String? vehicleTypeID;

  VehicleData({
    this.vehicleId,
    this.driverId,
    this.make,
    this.model,
    this.licensePlate,
    this.capacity,
    this.vehicleTypeID,
  });

  factory VehicleData.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VehicleData(
      vehicleId: doc.id,
      driverId: data['driverId'],
      make: data['make'],
      model: data['model'],
      licensePlate: data['licensePlate'],
      capacity: data['capacity'],
      vehicleTypeID: data['vehicleTypeID'],
    );
  }
}
