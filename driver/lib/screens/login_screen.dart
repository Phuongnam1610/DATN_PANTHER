import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/splashScreen/splash_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:driver/global/global.dart';
import 'package:driver/screens/forgot_password_screen.dart';
import 'package:driver/screens/main_screen.dart';
import 'package:driver/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;
  String? _selectedGender;

  void _submnit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text)
          .then((auth) async {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('Users').doc(auth.user!.uid);
        DocumentSnapshot userDoc = await userRef.get();
        if (userDoc.exists && userDoc.get('role') == 'driver') {
          currentUser = auth.user;
          await Fluttertoast.showToast(msg: "Login Success");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainScreen()));
        } else {
          await Fluttertoast.showToast(msg: "Tài khoản không tồn tại");
          firebaseAuth.signOut();
        }
      }).catchError((errorMessage) {
        Fluttertoast.showToast(
            msg: "Loi khi dang nhap, vui long thu lai sau" +
                errorMessage.toString());
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
                        _signinText(),
                        const SizedBox(height: 20),
                        _emailField(context),
                        const SizedBox(height: 20),
                        _passWordField(context),
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
                              "Log in",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(height: 20),
                        _rowLineOneOne(context),
                        const SizedBox(height: 10),
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) =>
                                          const ForgotPasswordScreen()));
                            },
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
                              const Text("Don't have an account?"),
                              const SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const RegisterScreen()));
                                  },
                                  child: Text(
                                    "Sign up",
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

  Widget _signinText() {
    return const Text(
      textAlign: TextAlign.left,
      "Sign in",
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
