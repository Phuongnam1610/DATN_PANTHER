import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/global/global.dart';
import 'package:driver/models/VehicleType_data.dart';
import 'package:driver/models/Vehicle_data.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:driver/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({Key? key}) : super(key: key);

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final _carModelTextEditingController = TextEditingController();
  final _carNumberTextEditingController = TextEditingController();
  final _carColorTextEditingController = TextEditingController();

  List<VehicleTypeData> _carTypes = [];
  VehicleTypeData? _selectedCarType;

  final _formKey = GlobalKey<FormState>();
  Future<void> _fetchCarTypes() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('VehicleTypes').get();
      setState(() {
        _carTypes = snapshot.docs.map((DocumentSnapshot doc) {
          return VehicleTypeData.fromDocument(doc);
        }).toList();
      });
    } catch (e) {
      print("Error fetching car types: $e");
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> userMap = {
        "model": _carModelTextEditingController.text,
        "licensePlate": _carNumberTextEditingController.text,
        "color": _carColorTextEditingController.text,
        "vehicleTypeId": _selectedCarType!.vehicleTypeId,
        "driverId": currentUser!.uid,
      };
      // Tạo document mới với ID tự động và lấy ID đó
      DocumentReference newVehicleRef =
          FirebaseFirestore.instance.collection('Vehicles').doc();
      String vehicleId = newVehicleRef.id;

      // Thêm vehicleId vào userMap
      userMap["vehicleId"] = vehicleId;

      // Lưu thông tin xe vào document mới sử dụng vehicleId làm document ID
      newVehicleRef.set(userMap);
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);
      userRef.update({"vehicleOnId": vehicleId});
      Fluttertoast.showToast(msg: "Car details has been saved");
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => SplashScreen()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCarTypes();
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
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image.asset(darkTheme ? 'images/pick' : 'images/city.jpg'),
                  _addCarText(),
                  const SizedBox(height: 20),
                  _carModelField(context),
                  const SizedBox(height: 20),
                  _carNumberField(context),
                  const SizedBox(height: 20),
                  _carColorField(context),

                  const SizedBox(height: 20),
                  _carTypeField(context),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        _submit();
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color.fromARGB(0, 238, 255, 0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 220, 216, 1),
                                  width: 2))),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),

                  const SizedBox(height: 10),
                  GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                            color: darkTheme ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text("Have an account?"),
                    const SizedBox(width: 10),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const LoginScreen()));
                        },
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                              color: darkTheme ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ))
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(80, 80),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: Color(0xffD0D0D0),
                                    width: 2,
                                  ))),
                          onPressed: () {},
                          child: SvgPicture.asset(
                            "images/google.svg",
                            width: 80,
                            height: 80,
                          ))
                    ],
                  )
                ],
              ), // Column
              // ... other widgets
            ],
          ),
        ), // ListView
      ), // Scaffold
    );
  }

  Widget _addCarText() {
    return const Text(
      textAlign: TextAlign.left,
      "Add Car Details",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _carModelField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: "Name",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your car model";
        }
        if (value.length < 3) {
          return "car model must be at least 3 characters";
        }
        if (value.length > 20) {
          return "car model must be less than 20 characters";
        }
        return null;
      },
      onChanged: (text) =>
          setState(() => _carModelTextEditingController.text = text),
    );
  }

  Widget _carNumberField(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return TextFormField(
      decoration: const InputDecoration(
        hintText: "Number Car",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your number car";
        }

        if (value.length < 3) {
          return "Number car must be at least 3 characters";
        }
        if (value.length > 9) {
          return "Number car must be less than 10 characters";
        }
        return null;
      },
      onChanged: (text) =>
          setState(() => _carNumberTextEditingController.text = text),
    );
  }

  Widget _carColorField(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return TextFormField(
      decoration: InputDecoration(
        hintText: "CarColor",
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your car color";
        }

        if (value.length < 3) {
          return "color must be at least 3 characters";
        }
        if (value.length > 49) {
          return "color must be less than 50 characters";
        }
        return null;
      },
      onChanged: (text) =>
          setState(() => _carColorTextEditingController.text = text),
    );
  }

  Widget _carTypeField(BuildContext context) {
    return DropdownButtonFormField<VehicleTypeData>(
      decoration: const InputDecoration(
        hintText: "Type",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      value: _selectedCarType,
      onChanged: (newValue) {
        setState(() {
          _selectedCarType = newValue!;
        });
      },
      items: _carTypes.map((carType) {
        return DropdownMenuItem<VehicleTypeData>(
          value: carType,
          child: Text(carType.type!),
        );
      }).toList(),
    );
  }
}
