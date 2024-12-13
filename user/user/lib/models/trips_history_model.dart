import 'package:cloud_firestore/cloud_firestore.dart';

class TripsHistoryModel {
  Timestamp? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  double? fareAmount;
  String? carDetails;
  double? voucherFare;

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.carDetails,
    this.voucherFare,
  });

  factory TripsHistoryModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TripsHistoryModel(
      time: data['createdAt'],
      originAddress: data['pickupAddress'],
      destinationAddress: data['dropoffAddress'],
      status: data['status'],
      fareAmount: data['fareAmount'],
      carDetails: data['car_details'],
      voucherFare: data['voucherFare'],
    );
  }
}
