import 'package:cloud_firestore/cloud_firestore.dart';

class DriverData {
  String? userId;
  String? name;
  String? phoneNumber;
  String? email;
  String? vehicleOnId;

  DriverData({
    this.userId,
    this.name,
    this.phoneNumber,
    this.email,
    this.vehicleOnId,
  });

  factory DriverData.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DriverData(
      userId: doc.id,
      email: data['email'],
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      vehicleOnId: data['vehicleOnId'],
    );
  }
}
