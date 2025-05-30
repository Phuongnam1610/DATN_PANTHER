import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driver/Assistants/assistant_request.dart';
import 'package:driver/global/global.dart';
import 'package:driver/global/map_key.dart';
import 'package:driver/infoHandler/app_info.dart';
import 'package:driver/models/directions.dart';
import 'package:driver/models/predicted_places.dart';
import 'package:driver/widgets/progress_dialog.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() =>
      _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Setting up Drop off, Please wait...",
      ),
    ); // Hiển thị hộp thoại chờ

    String placeDirectionDetailsUrl =
        "https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeId&key=$map_key";

    //gọi api lấy chi tiết địa diểm dựa trên place_id
    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context); //ẩn hộp thoại

    if (responseApi == 'Error Occurred, Failed. No Response.') {
      return;
    }
    if (responseApi['status'] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi['result']['name'];
      directions.locationId = placeId;
      directions.locationLatitude =
          responseApi['result']['geometry']['location']['lat'];
      directions.locationLongitude =
          responseApi['result']['geometry']['location']['lng'];
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);
      setState(() {
        // userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
      },
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.predictedPlaces!.main_text ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16.0,
                          color: darkTheme ? Colors.black : Colors.blue),
                    ),
                    Text(widget.predictedPlaces!.secondary_text ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            color: darkTheme ? Colors.black : Colors.blue))
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
