import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/global/global.dart';
import 'package:user/models/trips_history_model.dart';
import 'package:user/themeProvider/AppColors.dart';
import 'package:user/widgets/history_design_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  bool _isLoading = true;
  int _completedTrips = 0;
  
  List<TripsHistoryModel> _tripHistoryList = [];

  Future<List<TripsHistoryModel>> _fetchTripHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Ride')
          .where('customerId', isEqualTo: currentUser!.uid)
          .get();

      _tripHistoryList = querySnapshot.docs.map((doc) {
        return TripsHistoryModel.fromDocument(doc);
      }).toList();
      return _tripHistoryList;
    } catch (e) {
      return [];
    }
  }

  Future<void> getEarnings() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("User")
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
        });
      }

      final RideQuery = await FirebaseFirestore.instance
          .collection("Ride")
          .where("customerId", isEqualTo: currentUser!.uid)
          .get();

      if (mounted) {
        setState(() {
          _completedTrips = RideQuery.docs.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;

        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getEarnings();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
 
    final textColor = darkTheme ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thu Nhập',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
        backgroundColor: darkTheme ? Colors.blueGrey[800] : AppColors.primary700,
                systemOverlayStyle: SystemUiOverlayStyle.light, // Set status bar color

      ),
      body: Padding(
        padding:  const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Earnings Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Tổng số chuyến đi hoàn thành",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            _completedTrips.toString(),
                            style: TextStyle(
                              fontSize: 66,
                              fontWeight: FontWeight.bold,
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.black,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          
            // Completed Trips Section
            
            //Nộp phí duy trì section
            
            
            const SizedBox(height: 20),
            Text("Lịch sử chuyến đi"),
            const SizedBox(height: 10,),
            Expanded(
              child: FutureBuilder(
                future: _fetchTripHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error fetching trip history'));
                  } else if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(0),
                      child: ListView.separated(
                        itemBuilder: (context, i) {
                          return Card(
                            color: Colors.grey[100],
                            shadowColor: Colors.transparent,
                            child: HistoryDesignUIWidget(
                              tripHistoryModel: _tripHistoryList[i],
                            ),
                          );
                        },
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: 5),
                        itemCount: _tripHistoryList.length,
                      ),
                    );
                  } else {
                    return const Center(
                        child: Text('No trip history found.'));
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}