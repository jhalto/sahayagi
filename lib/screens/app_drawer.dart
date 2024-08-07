import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sahayagi/screens/manage_friends.dart';
import 'package:sahayagi/screens/update_profile.dart';
import 'package:sahayagi/screens/change_password.dart';

import '../helpers/helper.dart';
import '../widget/common_widget.dart';
import 'search_friend.dart';
import 'manage_friend_request_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Drawer(
        child: Center(
          child: Text('User not signed in', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Drawer(
      backgroundColor: Colors.blue,
      child: ListView(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                return const Text('No user data available', style: TextStyle(color: Colors.white));
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>?;
              if (userData == null) {
                return const Text('User data is empty', style: TextStyle(color: Colors.white));
              }

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
                      backgroundImage: userData['photoUrl'] != null ? NetworkImage(userData['photoUrl']) : null,
                      child: userData['photoUrl'] == null ? Icon(Icons.person, size: 30) : null,
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                return const Text('No user data available', style: TextStyle(color: Colors.white));
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>?;
              if (userData == null) {
                return const Text('User data is empty', style: TextStyle(color: Colors.white));
              }

              return Column(
                children: [
                  ListTile(
                    title: Text("Blood Group: ${userData['blood_group'] ?? ''}", style: appFontStyle(20, texColorLight)),
                  ),
                  ListTile(
                    title: Text("Skills: ${_formatSkills(userData['skills'])}", style: appFontStyle(20, texColorLight)),
                  ),
                  ListTile(
                    title: Text("SubDistrict: ${userData['sub_district'] ?? ''}", style: appFontStyle(20, texColorLight)),
                  ),
                  ListTile(
                    title: Text("District: ${userData['district'] ?? ''}", style: appFontStyle(20, texColorLight)),
                  ),
                ],
              );
            },
          ),
          ListTile(
            title: Text('Search Friend', style: TextStyle(color: texColorLight)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendRequestPage()),
              );
            },
          ),
          ListTile(
            title: Text('Manage Friend Requests', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageFriendRequestsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: texColorLight),
            title: Text('Friend List', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageFriendsPage(),
                ),
              );
            },
          ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20, top: 20),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       MyHelper().logOut(context);
          //     },
          //     child: Text("Log Out", style: appFontStyle(20, texColorDark, FontWeight.bold)),
          //   ),
          // ),
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
          Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40, top: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
              },
              child: Text("Change Password", style: appFontStyle(15, texColorDark, FontWeight.bold)),
            ),
          ),
          IconButton(color: Colors.yellow,onPressed: (){
            MyHelper().logOut(context);
          }, icon: Icon(Icons.logout,color: Colors.white,size: 30,),)
        ],
      ),


    );
  }

  String _formatSkills(dynamic skills) {
    if (skills is List) {
      return skills.join(', ');
    }
    return '';
  }
}