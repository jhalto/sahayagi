



import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/helpers/notification_services.dart';
import 'package:sahayagi/screens/all_user.dart';
import 'package:sahayagi/screens/blood_post.dart';
import 'package:sahayagi/screens/edit_posted_events.dart';
import 'package:sahayagi/screens/notification_page.dart';
import 'package:sahayagi/screens/posted_blood_post.dart';
import 'package:sahayagi/screens/suggested_blood_donation_post.dart';
import 'package:sahayagi/screens/suggested_events.dart';
import 'package:sahayagi/screens/posted_events.dart';
import 'package:sahayagi/screens/user_profile.dart';
import 'package:sahayagi/screens/user_story.dart';
import 'package:sahayagi/widget/common_widget.dart';
import '../screens/applied_events.dart';
import '../screens/event_post.dart';
import '../screens/home_page.dart';


class ConvexBarDemo extends StatefulWidget {
  const ConvexBarDemo({super.key});

  @override
  State<ConvexBarDemo> createState() => _ConvexBarDemoState();
}

class _ConvexBarDemoState extends State<ConvexBarDemo> {
  NotificationServices notificationServices = NotificationServices();


  List<Widget> pages = [HomePage(),SuggestedEvents(),SuggestedBloodPosts(),NotificationsPage()];
  int index =0;
  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.foregroundMessage();

    notificationServices.getDeviceToken().then((value) {
      print('device token: ${value}');
    });
    notificationServices.getRefreshToken();


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:pages[index],


      bottomNavigationBar: ConvexAppBar(
          top: -5,




          initialActiveIndex: index,
          activeColor: Colors.white,
          style: TabStyle.react,
          backgroundColor: appColorDark,
          curveSize: 50,
          shadowColor: Colors.blue,


          onTap: (val){
            setState(() {
              index=val;
            });
          },
          items: const [
            TabItem(icon: Icon(Icons.home,color: texColorLight,)),

            TabItem(icon: Icon(Icons.event_available,color: texColorLight)),


            TabItem(icon: Icon(Icons.bloodtype,color: texColorLight)),
            TabItem(icon: Icon(Icons.notification_add,color: texColorLight)),

          ]),

    );
  }
}
