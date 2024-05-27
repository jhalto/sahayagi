import 'package:flutter/material.dart';
import 'package:sahayagi/helpers/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String? userName;
  String? userNumber;
  String? userPostOffice;
  String? userSubDistrict;
  String? userDistrict;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchUserNumber();
    _fetchUserPostOffice();
  }

  void _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? name = await MyHelper().getUserName(user.uid);
      setState(() {
        userName = name;

      });
    }
  }
  void _fetchUserNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? number = await MyHelper().getUserNumber(user.uid);
      setState(() {
        userNumber = number;
      });
    }
  }
  void _fetchUserPostOffice() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? postOffice = await MyHelper().getUserPostOffice(user.uid);
      setState(() {
        userPostOffice= postOffice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${userName ?? "User"}'),
      ),
      body: Center(
        child: Text('Hello, ${userPostOffice ?? "User"}'),
      ),
    );
  }
}