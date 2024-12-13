import 'package:user/widgets/custom_appbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user/global/global.dart';

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
        Fluttertoast.showToast(msg: "Email đã gửi");
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: errorMessage.toString());
      });
    } else {
      Fluttertoast.showToast(msg: "Vui lòng nhập email hợp lệ");
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
             appBar: CustomAppBar(
        title: "",
        onBackPressed: () {
          Navigator.pop(context); // Hành động quay lại
        },),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _forgotText(),
                            const SizedBox(height: 20),
                            _emailField(context),
                            const SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () {
                                  _submnit();
                                },
                                 style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: const Color(0xFFEDAE10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                          color: const Color(0xFFEDAE10),
                                          width: 2))),
                                child: const Text(
                                  "Gửi yêu cầu",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )),
                          ]),
                    )),
              ),
            )));
  }

  Widget _forgotText() {
    return const Text(
      textAlign: TextAlign.left,
      "Quên mật khẩu",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _emailField(BuildContext context) {
   
    return TextFormField(
      decoration: const InputDecoration(
        hintText: "Email",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Vui lòng nhập email";
        }
        if (EmailValidator.validate(value) == true) {
          return null;
        }
       else {
          return "Email không hợp lệ";
        }
      },
      onChanged: (text) => setState(() => _emailController.text = text),
    );
  }
}
