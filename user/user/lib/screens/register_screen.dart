import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/screens/main_screen.dart';
import 'package:user/splashScreen/splash_screen.dart';
import 'package:user/themeProvider/AppColors.dart';
import 'package:user/widgets/custom_appbar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:user/global/global.dart';
import 'package:user/screens/login_screen.dart';
import 'package:path/path.dart' as path;


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;
  String? _selectedGender;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;

  Future getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImageToFirebase() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('User/${path.basename(_image!.path)}');
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      Fluttertoast.showToast(msg: "Lỗi tải lên ảnh");
    }
  }

  void _submnit() async {
    if (_formKey.currentState!.validate()) {
         if (_image == null) {
        Fluttertoast.showToast(msg: "Vui lòng chọn ảnh");
        return;
      }
      
      await uploadImageToFirebase();
      if(imageUrl == null) {
        Fluttertoast.showToast(msg: "Lỗi khi tải ảnh lên");
        return;
      }
      await firebaseAuth
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text)
          .then((auth) async {
        currentUser = auth.user;
        if (currentUser != null) {
          Map<String, String> userMap = {
            "userId": currentUser!.uid,
            "name": _nameController.text,
            "email": _emailController.text,
            "gender": _selectedGender!,
            "imageUrl": imageUrl!,

            "phoneNumber": _passwordController.text,
            "role": "user",
          };
          CollectionReference userCollection =
              FirebaseFirestore.instance.collection('User');
          userCollection.doc(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Đăng ký thành công");
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SplashScreen()));
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: errorMessage.toString());
      });
    } else {
      Fluttertoast.showToast(msg: "Vui lòng điền thông tin hợp lệ");
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
        title: "Đăng ký",
        onBackPressed: () {
          Navigator.pop(context); // Hành động quay lại
        },),
            body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                      child: Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(_image!),
                          )
                              : const CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage('images/default_profile.jpg'), // Replace with your default image
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => _imageSourceBottomSheet(),
                                );
                              },
                              icon: const Icon(Icons.add_a_photo, size: 30),
                            ),
                          ),
                        ],
                      ),
                    ),
                     const SizedBox(height: 20),
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
                        // _termsField(context),
                        // const SizedBox(height: 20),  
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
                              "Đăng ký",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(height: 20),
                        _rowLineOneOne(context),
                        const SizedBox(height: 10),
                        
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //thêm textstyle

                              Text("Đã có tài khoản?",style: TextStyle(
                                    color: AppColors.grey700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),),
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
                                    "Đăng Nhập",
                                    style: TextStyle(
                                        color: AppColors.primary700,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ))
                            ]),
                        const SizedBox(height: 20),
                       
                      ]),
                )),
          ),
        )));
  }

  Widget _signupText() {
    return const Text(
      textAlign: TextAlign.left,
      "Đăng ký",
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _nameField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: "Tên",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Vui lòng nhập tên";
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
          return "Vui lòng nhập mật khẩu";
        }

        if (value.length < 6) {
          return "Mật khẩu phải có ít nhất 6 ký tự";
        }
        if (value.length > 49) {
          return "Mật khẩu không được quá 50 ký tự";
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
          return "Vui lòng nhập lại mật khẩu";
        }
        if (value != _passwordController.text) {
          return "Mật khẩu không khớp";
        }

        if (value.length < 6) {
          return "Mật khẩu phải có ít nhất 6 ký tự";
        }
        if (value.length > 49) {
          return "Mật khẩu không được quá 50 ký tự";
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
        disableLengthCheck: true,
        onChanged: (text) => setState(() {
              _mobileController.text = text.completeNumber;
            }));
  }


Widget _genderField(BuildContext context) {
  final List<String> genders = ['Nam', 'Nữ', 'Khác'];

  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: 'Giới tính',
      labelStyle: TextStyle(color: Colors.grey[700]), // Customize label style
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
        borderSide: BorderSide(color: Colors.grey), // Customize border color
      ),
      filled: true, // Fill the input field
      fillColor: Colors.grey[100], // Set fill color
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add padding
    ),
    value: _selectedGender, // Initial value, will be null initially
    items: genders.map((gender) {
      return DropdownMenuItem<String>(
        value: gender,
        child: Text(gender, style: TextStyle(fontSize: 16)), // Customize item text style
      );
    }).toList(),
    onChanged: (String? newValue) {
      _selectedGender = newValue;

    },
    validator: (value) {
      // Add validation if required
      if (value == null) {
        return 'Vui lòng chọn giới tính';
      }
      return null;
    },
  );
}

  Widget _termsField(BuildContext context) {
    return Row(children: [
      Checkbox(value: true, onChanged: (value) {}),
      const Text("Tôi đồng ý với điều khoản sử dụng")
    ]);
  }

  Widget _imageSourceBottomSheet() {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Gallery'),
          onTap: () {
            getImage(ImageSource.gallery);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Camera'),
          onTap: () {
            getImage(ImageSource.camera);
            Navigator.of(context).pop();
          },
        ),]
      ,
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
