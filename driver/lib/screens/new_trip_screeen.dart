import 'package:driver/models/user_ride_request_information.dart';
import 'package:flutter/material.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NewTripScreen({
    this.userRideRequestDetails,
  });

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
