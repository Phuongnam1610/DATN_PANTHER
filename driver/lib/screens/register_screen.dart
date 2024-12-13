import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/screens/car_info_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:driver/global/global.dart';
import 'package:driver/screens/login_screen.dart';
import 'package:driver/screens/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;
  String? _selectedGender;

  void _submnit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text)
          .then((auth) async {
        currentUser = auth.user;
        if (currentUser != null) {
          Map<String, dynamic> userMap = {
            "userId": currentUser!.uid,
            "name": _nameController.text,
            "email": _emailController.text,
            "gender": _selectedGender!,
            "phoneNumber": _passwordController.text,
            "role": "driver",
            "weeklyFeeStatus": false,
            "banned": false,
            "rating": 0,
          };
          CollectionReference userCollection =
              FirebaseFirestore.instance.collection('Users');
          userCollection.doc(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Register Success");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const CarInfoScreen()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: errorMessage.toString());
      });
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _signupText(),
                        const SizedBox(height: 20),
                        _nameField(context),
                        const SizedBox(height: 20),
                        _emailField(context),
                        const SizedBox(height: 20),
                        _passWordField(context),
                        const SizedBox(height: 20),
                        _confirmPassWordField(context),
                        const SizedBox(height: 20),
                        _mobileField(context),
                        const SizedBox(height: 20),
                        _genderField(context),
                        const SizedBox(height: 20),
                        _termsField(context),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () {
                              _submnit();
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor:
                                    const Color.fromARGB(0, 238, 255, 0),
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
                        const SizedBox(height: 20),
                        _rowLineOneOne(context),
                        const SizedBox(height: 10),
                        GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                  color:
                                      darkTheme ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Have an account?"),
                              const SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const LoginScreen()));
                                  },
                                  child: Text(
                                    "Sign in",
                                    style: TextStyle(
                                        color: darkTheme
                                            ? Colors.white
                                            : Colors.black,
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
                      ]),
                ))));
  }

  Widget _signupText() {
    return const Text(
      textAlign: TextAlign.left,
      "Sign up",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _nameField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: "Name",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your name";
        }
        if (value.length < 3) {
          return "Name must be at least 3 characters";
        }
        if (value.length > 20) {
          return "Name must be less than 20 characters";
        }
        return null;
      },
      onChanged: (text) => setState(() => _nameController.text = text),
    );
  }

  Widget _emailField(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return TextFormField(
      decoration: const InputDecoration(
        hintText: "Email",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        if (EmailValidator.validate(value) == true) {
          return null;
        }
        if (value.length < 3) {
          return "Email must be at least 3 characters";
        }
        if (value.length > 99) {
          return "Email must be less than 100 characters";
        }
        return null;
      },
      onChanged: (text) => setState(() => _emailController.text = text),
    );
  }

  Widget _passWordField(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return TextFormField(
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
          hintText: "Password",
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: darkTheme ? Colors.white : Colors.black,
              ))).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your password";
        }

        if (value.length < 6) {
          return "password must be at least 3 characters";
        }
        if (value.length > 49) {
          return "password must be less than 50 characters";
        }
        return null;
      },
      onChanged: (text) => setState(() => _passwordController.text = text),
    );
  }

  Widget _confirmPassWordField(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return TextFormField(
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
          hintText: "Confirm Password",
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: darkTheme ? Colors.white : Colors.black,
              ))).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your confirmpassword";
        }
        if (value != _passwordController.text) {
          return "Passwords do not match";
        }

        if (value.length < 6) {
          return "password must be at least 3 characters";
        }
        if (value.length > 49) {
          return "password must be less than 50 characters";
        }
        return null;
      },
      onChanged: (text) =>
          setState(() => _confirmPasswordController.text = text),
    );
  }

  Widget _mobileField(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return IntlPhoneField(
        showCountryFlag: true,
        dropdownIcon: Icon(
          Icons.arrow_drop_down,
          color: darkTheme ? Colors.white : Colors.black,
        ),
        initialCountryCode: 'VN',
        onChanged: (text) => setState(() {
              _mobileController.text = text.completeNumber;
            }));
  }

  Widget _genderField(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        hintText: "Gender",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      value: _selectedGender,
      onChanged: (newValue) {
        setState(() {
          _selectedGender = newValue!;
        });
      },
      items: <String>['Male', 'Female', 'Other'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _termsField(BuildContext context) {
    return Row(children: [
      Checkbox(value: true, onChanged: (value) {}),
      const Text("I agree to the terms and conditions")
    ]);
  }

  Widget _rowLineOneOne(BuildContext context) {
    return Container(
        child: const Row(children: [
      Expanded(
        child: Divider(color: Color(0xffB8B8B8)),
      ),
      SizedBox(width: 6),
      Text(
        'or',
        style: TextStyle(
            color: Color(0xffB8B8B8),
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
      SizedBox(width: 6),
      Expanded(
        child: Divider(color: Color(0xffB8B8B8)),
      ),
    ]));
  }
}
