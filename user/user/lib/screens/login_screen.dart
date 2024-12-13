import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user/global/global.dart';
import 'package:user/screens/forgot_password_screen.dart';
import 'package:user/screens/main_screen.dart';
import 'package:user/screens/register_screen.dart';
import 'package:user/splashScreen/splash_screen.dart';
import 'package:user/themeProvider/AppColors.dart';
import 'package:user/widgets/custom_appbar.dart';
import 'package:user/widgets/custom_text.dart';
import 'package:user/widgets/custom_text_field.dart';
import 'package:user/widgets/elevated_button_theme.dart';

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
            FirebaseFirestore.instance.collection('User').doc(auth.user!.uid);
        DocumentSnapshot userDoc = await userRef.get();
        if (userDoc.exists && userDoc.get('role') == 'user') {
          currentUser = auth.user;
          await Fluttertoast.showToast(msg: "Login Success");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => const SplashScreen()));
        } else {
          await Fluttertoast.showToast(msg: "User already exist");
          firebaseAuth.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => SplashScreen()));
        }
      }).catchError((errorMessage) {
        Fluttertoast.showToast(
            msg: "Lỗi khi đăng nhập vui lòng thử lại sau$errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Lỗi khi đăng nhập vui lòng thử lại sau");
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
        },
      ),
            body: SafeArea(
      
            child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _signinText(),
                        const SizedBox(height: 20),
                        _emailField(context),
                        const SizedBox(height: 20),
                        _passWordField(context),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) =>
                                          const ForgotPasswordScreen()));
                            },
                            child: Text(
                              "Quên Mật Khẩu?",
                              style: TextStyle(
                                  color:AppColors.errorColor),
                            )),
                        ),
                        const SizedBox(height: 40),
                        CustomElevatedButton(
                          onPressed: () {
                            _submnit();
                          }, text: 'Đăng Nhập',
                        
                        ),
                        const SizedBox(height: 20),
                        _rowLineOneOne(context),
                        const SizedBox(height: 10),
                        
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Không có tài khoản?",
                                style: TextStyle(
                                    color: AppColors.grey700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
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
                                    "Đăng ký",
                                    style: TextStyle(
                                        color: AppColors.primary700,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ))
                            ]),
                      
                      ]),
                )),
   
        )));
  }

  Widget _signinText() {
    return CustomText(
       text: "Đăng Nhập",
       fontSize: 20,

    );
  }

  Widget _emailField(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return CustomTextField(
      hintText: "Email",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Vui lòng nhập email";
        }
        if (EmailValidator.validate(value) == true) {
          return null;
        } else {
          return "Email không hợp lệ";
        }

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
        border: const OutlineInputBorder(), // Customize border as needed
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor), // Customize focused border
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red), // Customize error border
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade700), // Customize focused error border
        ),
          hintText: "Mật khẩu",
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
          return "Vui lòng nhập email";
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
        'Hoặc',
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
