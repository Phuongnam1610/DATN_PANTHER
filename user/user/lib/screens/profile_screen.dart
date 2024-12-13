import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user/global/global.dart';
import 'package:user/splashScreen/splash_screen.dart';
import 'package:user/themeProvider/AppColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final genderTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  DocumentReference userRef =
      FirebaseFirestore.instance.collection('User').doc(currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tài khoản',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          backgroundColor: darkTheme ? Colors.blueGrey[800] : AppColors.primary700,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: userModelCurrentInfo!.imageUrl != null && userModelCurrentInfo!.imageUrl!.isNotEmpty
                          ? NetworkImage(userModelCurrentInfo!.imageUrl!)
                          : const AssetImage('images/default_profile.jpg'),
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "${userModelCurrentInfo?.name ?? 'Unknown User'}",
                      style: TextStyle(
                        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildProfileSection(),
                  ],
                ),
              ),
             ] ,
          ),
        ),
      ),
    );
  }

  Widget buildProfileSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildProfileRow('Họ tên', userModelCurrentInfo!.name!, updateName),
            buildProfileRow('Email', userModelCurrentInfo!.email!, updateEmail),
            buildProfileRow('Giới tính', userModelCurrentInfo!.gender!, updateGender),
            buildProfileRow('Số điện thoại', userModelCurrentInfo!.phoneNumber!, updatePhoneNumber),
            const SizedBox(height: 20),
            buildChangePasswordButton(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => SplashScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileRow(String label, String value, Function dialogFunction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 18),
              ),
              IconButton(
                onPressed: () => dialogFunction(context, value),
                icon: const Icon(Icons.edit),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }


  Future<void> updateName(BuildContext context, String name) async {
    nameTextEditingController.text = name;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật họ tên'),
        content: TextFormField(
          controller: nameTextEditingController,
          decoration: const InputDecoration(labelText: 'Nhập họ tên mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              userRef.update({'name': nameTextEditingController.text.trim()}).then((value) {
                Fluttertoast.showToast(msg: "Cập nhật thành công");
                setState(() {
                  userModelCurrentInfo!.name = nameTextEditingController.text.trim();
                });
              }).catchError((error) {
                Fluttertoast.showToast(msg: "Cập nhật thất bại: " + error.toString());
              });
              Navigator.pop(context);
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  Future<void> updateEmail(BuildContext context, String email) async {
    emailTextEditingController.text = email;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật Email'),
        content: TextFormField(
          controller: emailTextEditingController,
          decoration: const InputDecoration(labelText: 'Nhập Email mới'),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              userRef.update({'email': emailTextEditingController.text.trim()}).then((value) {
                Fluttertoast.showToast(msg: "Cập nhật thành công");
                setState(() {
                  userModelCurrentInfo!.email = emailTextEditingController.text.trim();
                });
              }).catchError((error) {
                Fluttertoast.showToast(msg: "Cập nhật thất bại: " + error.toString());
              });
              Navigator.pop(context);
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  Future<void> updateGender(BuildContext context, String gender) async {
    genderTextEditingController.text = gender;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật Giới tính'),
        content: TextFormField(
          controller: genderTextEditingController,
          decoration: const InputDecoration(labelText: 'Nhập Giới tính mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              userRef.update({'gender': genderTextEditingController.text.trim()}).then((value) {
                Fluttertoast.showToast(msg: "Cập nhật thành công");
                setState(() {
                  userModelCurrentInfo!.gender = genderTextEditingController.text.trim();
                });
              }).catchError((error) {
                Fluttertoast.showToast(msg: "Cập nhật thất bại: " + error.toString());
              });
              Navigator.pop(context);
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  Future<void> updatePhoneNumber(BuildContext context, String phone) async {
    phoneTextEditingController.text = phone;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật số điện thoại'),
        content: TextFormField(
          controller: phoneTextEditingController,
          decoration: const InputDecoration(labelText: 'Nhập số điện thoại mới'),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              userRef.update({'phone': phoneTextEditingController.text.trim()}).then((value) {
                Fluttertoast.showToast(msg: "Cập nhật thành công");
                setState(() {
                  userModelCurrentInfo!.phoneNumber = phoneTextEditingController.text.trim();
                });
              }).catchError((error) {
                Fluttertoast.showToast(msg: "Cập nhật thất bại: " + error.toString());
              });
              Navigator.pop(context);
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  Widget buildChangePasswordButton() {
    return ElevatedButton(
      onPressed: () => showChangePasswordDialog(context),
      child: const Text('Đổi mật khẩu'),
    );
  }

  Future<void> showChangePasswordDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => changePassword(),
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword() async {
    String oldPassword = oldPasswordController.text.trim();
    String newPassword = newPasswordController.text.trim();

    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: userModelCurrentInfo!.email!,
        password: oldPassword,
      );

      await user!.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      Fluttertoast.showToast(msg: "Đổi mật khẩu thành công");
      oldPasswordController.clear();
      newPasswordController.clear();
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Đổi mật khẩu thất bại: ${e.toString()}");
    }
  }
}