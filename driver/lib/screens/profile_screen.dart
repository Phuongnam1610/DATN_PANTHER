import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:driver/global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();

  DocumentReference userRef =
      FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid);

  Future<void> _showUserNameDialogAlert(BuildContext context, String name) {
    nameTextEditingController.text = name;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameTextEditingController,
                  // TextFormField
                ),
                // Column
              ],
            ),
            // SingleChildScrollView
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              // TextButton
            ),
            TextButton(
              onPressed: () {
                userRef.update({
                  'name': nameTextEditingController.text.trim(),
                }).then((value) {
                  nameTextEditingController.clear();
                  Fluttertoast.showToast(msg: "Update successfully");
                }).catchError((error) {
                  Fluttertoast.showToast(
                      msg: "Update failed" + error.toString());
                });
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Colors.black)),
              // TextButton
            ),
            // AlertDialog
          ],
        );
      },
    );
  }

  Future<void> _showUserPhoneDialogAlert(BuildContext context, String phone) {
    phoneTextEditingController.text = phone;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: phoneTextEditingController,
                  // TextFormField
                ),
                // Column
              ],
            ),
            // SingleChildScrollView
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              // TextButton
            ),
            TextButton(
              onPressed: () {
                userRef.update({
                  'phone': phoneTextEditingController.text.trim(),
                }).then((value) {
                  phoneTextEditingController.clear();
                  Fluttertoast.showToast(msg: "Update successfully");
                }).catchError((error) {
                  Fluttertoast.showToast(
                      msg: "Update failed" + error.toString());
                });
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Colors.black)),
              // TextButton
            ),
            // AlertDialog
          ],
        );
      },
    );
  }

  Future<void> _showUserEmailDialogAlert(BuildContext context, String email) {
    emailTextEditingController.text = email;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: emailTextEditingController,
                  // TextFormField
                ),
                // Column
              ],
            ),
            // SingleChildScrollView
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              // TextButton
            ),
            TextButton(
              onPressed: () {
                userRef.update({
                  'email': emailTextEditingController.text.trim(),
                }).then((value) {
                  emailTextEditingController.clear();
                  Fluttertoast.showToast(msg: "Update successfully");
                }).catchError((error) {
                  Fluttertoast.showToast(
                      msg: "Update failed" + error.toString());
                });
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Colors.black)),
              // TextButton
            ),
            // AlertDialog
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          // IconButton
          title: Text(
            'Profile Screen',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ), // AppBar
        body: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle,
                  ), // BoxDecoration
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ), // Container
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${userModelCurrentInfo!.name!}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ), // TextStyle
                    ),
                    IconButton(
                      onPressed: () {
                        _showUserNameDialogAlert(
                            context, userModelCurrentInfo!.name!);
                      },
                      icon: Icon(
                        Icons.edit,
                      ), // Icon
                    ), // IconButton
                    // Text
                  ],
                ), // Row
                Divider(
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${userModelCurrentInfo!.name!}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ), // TextStyle
                    ),
                    IconButton(
                      onPressed: () {
                        _showUserEmailDialogAlert(
                            context, userModelCurrentInfo!.email!);
                      },
                      icon: Icon(
                        Icons.edit,
                      ), // Icon
                    ), // IconButton
                    // Text
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${userModelCurrentInfo!.phoneNumber!}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ), // TextStyle
                    ),
                    IconButton(
                      onPressed: () {
                        _showUserNameDialogAlert(
                            context, userModelCurrentInfo!.gender!);
                      },
                      icon: Icon(
                        Icons.edit,
                      ), // Icon
                    ), // IconButton
                    // Text
                  ],
                ),
                Divider(
                  thickness: 1,
                ),
                Text(
                  '${userModelCurrentInfo!.email!}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ), // TextStyle
                ),
              ],
            ),
          ),
        ), // Center
      ), // Scaffold
    ); // GestureDetector
  }
}
