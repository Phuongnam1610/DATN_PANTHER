import 'package:flutter/material.dart';
import 'package:user/Assistants/assistant_request.dart';
import 'package:user/global/map_key.dart';
import 'package:user/models/predicted_places.dart';
import 'package:user/widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  //Danh sách lưu trữ
  List<PredictedPlaces> placesPredictedList = [];
  //async cho biết hàm này bất đồng bộ
  findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      //Nếu độ dài không lớn hơn 1 sẽ ko thực thi giúp tránh gửi yêu cầu tìm kiếm không cần
      //thiết khi người dùng chưa nhập đủ ký tự
      String urlAutoCompleteSearch =
          "https://maps.gomaps.pro/maps/api/place/autocomplete/json?input=$inputText&key=$map_key";

      var responseAutoCompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch ==
          "Error Occurred. Failed. No Response.") {
        return;
      }

      if (responseAutoCompleteSearch["status"] == "OK") {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List)
            .map((e) => PredictedPlaces.fromJson(e))
            .toList();

        setState(() {
          //Cập nhật giá trị của biến placesPredictedList
          //trong state của widget
          //kích hoạt flutter rebuild lại giao diện người dùng, hiển thị danh sách địa điểm dự đoán mới
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: darkTheme ? Colors.black : Colors.white,
            appBar: AppBar(
              backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: darkTheme ? Colors.black : Colors.white,
                ),
              ),
              title: GestureDetector(
                // // Gesture detector
                child: Text(
                  'Tìm kiếm điểm trả',
                  style:
                      TextStyle(color: darkTheme ? Colors.black : Colors.white),
                ),
              ),
              elevation: 0.0,
            ),
            body: Column(children: [
              Container(
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white54,
                      blurRadius: 8,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ), // Offset
                  ], // BoxShadow
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(children: [
                        Icon(
                          Icons.adjust_sharp,
                          color: darkTheme ? Colors.black : Colors.white,
                        ), // Icon
                        SizedBox(height: 18.0),

                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.all(8),
                                child: TextField(
                                    onChanged: (value) {
                                      findPlaceAutoCompleteSearch(value);
                                    },
                                    decoration: InputDecoration(
                                        hintText: "Tìm kiếm địa chỉ...",
                                        fillColor: darkTheme
                                            ? Colors.black
                                            : Colors.white54,
                                        filled: true,
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                          left: 11,
                                          top: 8,
                                          bottom: 8,
                                        ))))),
                      ])
                    ],
                  ),
                ),
              ),
              (placesPredictedList.isNotEmpty)
                  ? Expanded(
                      child: ListView.separated(
                        itemCount: placesPredictedList.length,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return PlacePredictionTileDesign(
                            predictedPlaces: placesPredictedList[index],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            height: 0,
                            color: darkTheme ? Colors.black : Colors.white,
                            thickness: 0,
                          );
                        },
                      ), // ListView.separated
                    )
                  : Container() // Expanded
            ])));
  }
}
