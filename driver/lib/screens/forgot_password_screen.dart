import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:driver/global/global.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  void _submnit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .sendPasswordResetEmail(email: _emailController.text.trim())
          .then((value) {
        Fluttertoast.showToast(msg: "Email Sent");
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
                        _forgotText(),
                        const SizedBox(height: 20),
                        _emailField(context),
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
                              "Log in",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )),
                      ]),
                ))));
  }

  Widget _forgotText() {
    return const Text(
      textAlign: TextAlign.left,
      "Forgot Password",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
}
