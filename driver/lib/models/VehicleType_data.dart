import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleTypeData {
  String? vehicleTypeId;
  String? type;
  double? baseFare;
  double? fareFor5km;
  double? fareFor10km;
  double? farePerKm;
  double? multiplier;

  VehicleTypeData({
    this.vehicleTypeId,
    this.type,
    this.baseFare,
    this.fareFor5km,
    this.fareFor10km,
    this.farePerKm,
    this.multiplier,
  });

  factory VehicleTypeData.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VehicleTypeData(
      vehicleTypeId: doc.id,
      type: data['type']?.toString(),
      baseFare: data['baseFare']?.toDouble(),
      fareFor5km: data['fareFor5km']?.toDouble(),
      fareFor10km: data['fareFor10km']?.toDouble(),
      farePerKm: data['farePerKm']?.toDouble(),
      multiplier: data['multiplier']?.toDouble(),
    );
  }
}
