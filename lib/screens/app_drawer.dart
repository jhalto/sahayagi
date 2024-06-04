import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/update_profile.dart';

import '../helpers/helper.dart';
import '../widget/common_widget.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: appColorDark,
      child: ListView(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              var userData = snapshot.data!.data() as Map<String, dynamic>;

              return DrawerHeader(
                decoration: const BoxDecoration(
                  color: texColorLight,
                ),
                padding: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: appColorDark,
                  ),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateUserProfile()),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: userData['imageUrl'] != null ? NetworkImage(userData['imageUrl']) : null,
                      child: userData['imageUrl'] == null ? Icon(Icons.person, size: 30) : null,
                    ),
                  ),
                  accountEmail: Text(userData['email'] ?? '', style: appFontStyle(15)),
                  accountName: Text(userData['name'] ?? '', style: appFontStyle(18, texColorLight, FontWeight.bold)),
                  currentAccountPictureSize: Size.fromRadius(30),
                ),
              );
            },
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              var userData = snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                children: [
                  ListTile(
                    title: Text("Skill: ${userData['skill'] ?? ''}", style: appFontStyle(20, texColorLight)),
                  ),
                  ListTile(
                    title: Text("SubDistrict: ${userData['subDistrict'] ?? ''}", style: appFontStyle(20, texColorLight)),
                  ),
                  ListTile(
                    title: Text("District: ${userData['district'] ?? ''}", style: appFontStyle(20, texColorLight)),
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 20),
            child: ElevatedButton(
              onPressed: () {
                MyHelper().logOut(context);
              },
              child: Text("Log Out", style: appFontStyle(20, texColorDark, FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateUserProfile()),
                );
              },
              child: Text("Edit Profile", style: appFontStyle(15, texColorDark, FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}