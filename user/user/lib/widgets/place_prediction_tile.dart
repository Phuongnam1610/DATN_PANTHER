import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/Assistants/assistant_request.dart';
import 'package:user/global/global.dart';
import 'package:user/global/map_key.dart';
import 'package:user/infoHandler/app_info.dart';
import 'package:user/models/directions.dart';
import 'package:user/models/predicted_places.dart';
import 'package:user/screens/precise_pickup_location.dart';
import 'package:user/widgets/progress_dialog.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTileDesign({super.key, this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() =>
      _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Vui lòng đợi...",
      ),
    ); // Hiển thị hộp thoại chờ

    String placeDirectionDetailsUrl =
        "https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeId&key=$map_key";

    //gọi api lấy chi tiết địa diểm dựa trên place_id
    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context); //ẩn hộp thoại

    if (responseApi == 'Error Occurred, Failed. No Response.') {
      return getPlaceDirectionDetails(placeId, context);

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
        userDropOffAddress = directions.locationName!;
      });
      //tắt màn hình tìm địa chỉ
      // Navigator.pop(context, "obtainedDropoff");
      var responseFromSearchScreen = await Navigator.push(
          context, MaterialPageRoute(builder: (c) => PrecisePickUpScreen()));
      if (responseFromSearchScreen == "obtainedDropoff") {
        Navigator.pop(context, "obtainedDropoff");
      }
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