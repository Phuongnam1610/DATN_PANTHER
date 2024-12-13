import 'package:user/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';

class FareAmountCollectionDialog extends StatefulWidget {
  double? totalFareAmount;

  FareAmountCollectionDialog(this.totalFareAmount);

  @override
  State<FareAmountCollectionDialog> createState() =>
      _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState
    extends State<FareAmountCollectionDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // RoundedRectangleBorder
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ), // BoxDecoration
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text(
              "Thu phí chuyến đi", // Corrected the typo "Asount"
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme
                    ? Colors.amber.shade400
                    : Colors.white, // Corrected "omber" to "amber"
                fontSize: 20,
              ),
            ),
            Text(
              widget.totalFareAmount
                  .toString(), // Assuming widget.totalFareAmount exists
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme
                    ? Colors.amber.shade400
                    : Colors
                        .white, // Corrected "omber" and "shade408" (probably a typo)
                fontSize: 50,
              ),
            ),
            SizedBox(height: 18),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Đây là tổng tiền chuyến đi. Vui lòng thanh toán cho tài xế", // Corrected "Inis" to "This"
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTheme
                      ? Colors.amber.shade400
                      : Colors
                          .white, // Corrected "omber" and added missing colon
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      darkTheme ? Colors.amber.shade400 : Colors.white,
                ),
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 10000), () {
                    if(mounted){
                    Navigator.pop(context, "Cash Paid");}
                    // Navigator.push(context,
                        // MaterialPageRoute(builder: (c) => SplashScreen()));
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Thu phí thành công",
                      style: TextStyle(
                        fontSize: 20,
                        color: darkTheme ? Colors.black : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.totalFareAmount
                          .toString(), // Assuming TotalFareAmount exists
                      style: TextStyle(
                        fontSize: 20, // Add fontSize here for consistency
                        color: darkTheme
                            ? Colors.black
                            : Colors.blue, // Add color for consistency
                        fontWeight:
                            FontWeight.bold, // Add fontWeight for consistency
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ), // Column
      ), // Container
    ); // Dialog
  }
}
