

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/helpers/helper.dart';
import 'package:sahayagi/screens/create_user_profile.dart';
import 'package:sahayagi/screens/profile.dart';
import '../widget/common_widget.dart';
import 'applied_events.dart';
import 'message.dart';
import 'opportunities.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? userName;
  String? userNumber;
  String? userPostOffice;
  String? userSubDistrict;
  String? userDistrict;
  String? userEmail;
  String? userSkill;
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchUserNumber();
    _fetchUserPostOffice();
    _fetchUserEmail();
    _fetchUserSubDistrict();
    _fetchUserDistrict();
    _fetchUserSkill();
    _fetchUserImageUrl();
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
  void _fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? email = await MyHelper().getUserEmail(user.uid);
      setState(() {
        userEmail = email;

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
  void _fetchUserSubDistrict() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? subDistrict = await MyHelper().getUserSubDistrict(user.uid);
      setState(() {
        userSubDistrict= subDistrict;
      });
    }
  }
  void _fetchUserDistrict() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? district = await MyHelper().getUserDistrict(user.uid);
      setState(() {
        userDistrict= district;
      });
    }
  }
  void _fetchUserSkill() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? skill = await MyHelper().getUserSkill(user.uid);
      setState(() {
        userSkill= skill;
      });
    }
  }
  void _fetchUserImageUrl() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? imageUrl = await MyHelper().getUserImageUrl(user.uid);
      setState(() {
        userImageUrl= imageUrl;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(

      backgroundColor: appColorLight,

      child: ListView(
        children: [
          DrawerHeader(


              decoration: const BoxDecoration(
                  color: appColorLight
              ),
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(

                decoration: const BoxDecoration(

                    color: appColorLight
                ),
                currentAccountPicture: const CircleAvatar(
                  child: Image(image: NetworkImage("")),
                ),
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${userEmail}",style: appFontStyle(15),),

                  ],
                ),

                accountName: Text("${userName}",style: appFontStyle(17),),
              )),
         ListTile(
           title: Text("Skill: ${userSkill}"),
         ),
          ListTile(
            title: Text("SubDistrict: ${userSubDistrict}"),
          ),
          ListTile(
            title: Text("District: ${userDistrict}"),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: TextButton(onPressed: (){

            MyHelper().logOut(context);
            setState(() {

            });
            }, child: Text("Log Out",style: appFontStyle(20,texColorDark,FontWeight.bold),)),
          ),

          TextButton(onPressed: (){
           Navigator.push(context, MaterialPageRoute(builder: (context) => VolunteerUserProfile(),));
           setState(() {

           });
          }, child: Text("update profile"))


        ],
      ),

    );
  }
}
