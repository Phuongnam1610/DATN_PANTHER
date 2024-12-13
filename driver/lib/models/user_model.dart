import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? email;
  String? gender;
  String? name;
  String? phoneNumber;
  String? userId;

  UserModel({
    this.email,
    this.gender,
    this.name,
    this.phoneNumber,
    this.userId,
  });

  // Hàm chuyển đổi từ DocumentSnapshot sang UserModel
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      email: data['email'],
      gender: data['gender'],
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      userId: data['userId'],
    );
  }
}
