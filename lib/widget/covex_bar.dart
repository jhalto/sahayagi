



import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import '../screens/applied_events.dart';
import '../screens/event_post.dart';
import '../screens/home_page.dart';
import '../screens/profile.dart';

class ConvexBarDemo extends StatefulWidget {
  const ConvexBarDemo({super.key});

  @override
  State<ConvexBarDemo> createState() => _ConvexBarDemoState();
}

class _ConvexBarDemoState extends State<ConvexBarDemo> {
  List<Widget> pages = [const HomePage(),const MyProfile(),const AppliedEvents(),const EventPost()];
  int index =0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:pages[index],


      bottomNavigationBar: ConvexAppBar(
          top: -5,




          initialActiveIndex: index,
          activeColor: Colors.white,
          style: TabStyle.react,
          backgroundColor: Colors.black,
          curveSize: 50,
          shadowColor: Colors.blue,



          onTap: (val){
            setState(() {
              index=val;
            });
          },
          items: const [
            TabItem(icon: Icon(Icons.home,color: Colors.orange,)),
            TabItem(icon: Icon(Icons.account_circle,color: Colors.orange)),
            TabItem(icon: Icon(Icons.event_available_rounded,color: Colors.orange)),
            TabItem(icon: Icon(Icons.post_add,color: Colors.orange)),
          ]),

    );
  }
}
