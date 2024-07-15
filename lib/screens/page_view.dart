import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/home_page.dart';
import 'package:sahayagi/screens/post_option.dart';
import 'package:sahayagi/screens/suggested_blood_donation_post.dart';
import 'package:sahayagi/screens/suggested_events.dart';
import 'package:sahayagi/screens/user_profile.dart';

import '../helpers/notification_services.dart';
import '../widget/common_widget.dart';
import 'manage_message.dart';
import 'notification_page.dart';

class AppPageView extends StatefulWidget {
  const AppPageView({super.key});

  @override
  State<AppPageView> createState() => _AppPageViewState();
}

class _AppPageViewState extends State<AppPageView> {
  NotificationServices notificationServices = NotificationServices();
  PageController? pageController;
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(initialPage: currentIndex);
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.foregroundMessage();

    notificationServices.getDeviceToken().then((value) {
      print('device token: ${value}');
    });
    notificationServices.getRefreshToken();
  }

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        endDrawer: AppDrawer(),
        appBar: AppBar(
          leading: user != null
              ? StreamBuilder<DocumentSnapshot>(
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

              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileDetail()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userData['photoUrl'] ?? ''),
                  ),
                ),
              );
            },
          )
              : const SizedBox.shrink(),
          toolbarHeight: 65,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                "Sahayagi",
                style: appFontStyle(30, texColorLight, FontWeight.bold),
              ),
              Text(
                "Volunteer BD",
                style: appFontStyle(15, texColorLight, FontWeight.w500, FontStyle.italic),
              )
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ManageMessagesPage()));
              },
              icon: Icon(Icons.message),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AppDrawer()));
              },
              icon: Icon(Icons.menu),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              color: Colors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton(0, Icons.home),
                  _buildNavButton(1, Icons.event_available),
                  _buildNavButton(2, Icons.bloodtype_outlined),
                  _buildNavButton(3, Icons.notification_important),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                children: [
                  HomePage(),
                  SuggestedEvents(),
                  SuggestedBloodPosts(),
                  NotificationsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(int index, IconData icon) {
    return IconButton(
      onPressed: () {
        setState(() {
          currentIndex = index;
          pageController!.jumpToPage(index);
        });
      },
      icon: Icon(
        icon,
        color: currentIndex == index ? Colors.yellow : Colors.white,
      ),
    );
  }
}