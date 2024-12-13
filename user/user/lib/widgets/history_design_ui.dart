import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/models/trips_history_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryDesignUIWidget extends StatelessWidget {
  final TripsHistoryModel? tripHistoryModel;

  const HistoryDesignUIWidget({Key? key, required this.tripHistoryModel}) : super(key: key);

  String formatDateAndTime(Timestamp? timestamp) {
  if (timestamp == null) {
    return "N/A";
  }
  DateTime dateTime = timestamp.toDate();
  DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss'); // Customize the format as needed.  See below for options.
  return dateFormat.format(dateTime);
}

  String formatAddress(String? address) {
    return address!.substring(0, min(address?.length ?? 0, 25)) + (address!.length > 25 ? "..." : "") ?? "N/A"; // Improved null safety
  }

  @override
  Widget build(BuildContext context) {
    if (tripHistoryModel == null) return const SizedBox.shrink();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)
      ,side: BorderSide.none),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDateAndTime(tripHistoryModel!.time),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column( // Changed to Column for vertical address display
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressItem(Icons.location_on, formatAddress(tripHistoryModel!.originAddress)),
                const SizedBox(height: 5), // Added spacing between addresses
                _buildAddressItem(Icons.location_on, formatAddress(tripHistoryModel!.destinationAddress), color: Colors.black),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Thu hộ", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(tripHistoryModel!.fareAmount ?? 0.00),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(IconData icon, String address, {Color color = Colors.blue}) {
    return Row(
      children: [
        CircleAvatar( // Using CircleAvatar for a cleaner look
          radius: 10,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded( // Added Expanded to allow address text to wrap if needed
          child: Text(address, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}