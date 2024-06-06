



import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/all_user.dart';
import 'package:sahayagi/screens/edit_posted_events.dart';
import 'package:sahayagi/screens/suggested_blood_donation_post.dart';
import 'package:sahayagi/screens/suggested_events.dart';
import 'package:sahayagi/screens/posted_events.dart';
import 'package:sahayagi/screens/profile.dart';
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
  List<Widget> pages = [const HomePage(),const AllEvents(),const PostedEvents(),AllUsers(),SuggestedBloodPosts()];
  int index =0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:pages[index],


      bottomNavigationBar: ConvexAppBar(
          top: -6,




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
            TabItem(icon: Icon(Icons.event_note_sharp,color: texColorLight)),
            TabItem(icon: Icon(Icons.post_add,color: texColorLight)),
            TabItem(icon: Icon(Icons.bloodtype,color: texColorLight)),

          ]),

    );
  }
}
