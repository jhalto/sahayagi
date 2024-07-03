import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sahayagi/screens/posted_blood_post.dart';
import 'package:sahayagi/screens/posted_events.dart';
import 'package:sahayagi/screens/search_friend.dart';
import 'package:sahayagi/screens/story_post.dart';
import 'package:sahayagi/screens/update_profile.dart';
import 'package:sahayagi/screens/user_story.dart';

import '../helpers/helper.dart';
import '../widget/common_widget.dart';
import 'change_password.dart';
import 'manage_friend_request_page.dart';
import 'manage_friends.dart';

class UserProfileDetail extends StatefulWidget {
  @override
  _UserProfileDetailState createState() => _UserProfileDetailState();
}

class _UserProfileDetailState extends State<UserProfileDetail> {
  final User? user = FirebaseAuth.instance.currentUser;
  String searchSkill = '';
  PageController ? pageController;
  int currentIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    pageController = PageController(
      initialPage: currentIndex,
    );

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(

          child: Column(

            children: [
              Expanded(child: Container(
                child: ListView(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData ||
                            snapshot.data == null ||
                            !snapshot.data!.exists) {
                          return Center(
                              child: Text('No user data available',
                                  style: TextStyle(color: Colors.white)));
                        }

                        var userData = snapshot.data!.data() as Map<String, dynamic>?;
                        if (userData == null) {
                          return Center(
                              child: Text('User data is empty',
                                  style: TextStyle(color: Colors.white)));
                        }

                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 260,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image:
                                            NetworkImage("${userData['coverPhotoUrl'] ?? ''}"),
                                          )),
                                    ),
                                    Positioned(
                                        bottom: 5,
                                        left: 15,
                                        child: CircleAvatar(
                                          maxRadius: 50,
                                          backgroundImage: NetworkImage(
                                              "${userData['photoUrl'] ?? ''}"),
                                        )),

                                    Positioned(
                                        top: 210,
                                        left: 140,
                                        child: Container(
                                            width: 250,
                                            child: Text(userData['bio'??'']))
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${userData['name'] ?? ''}",
                                          style: textBlackBold(22)),
                                      Text(
                                        "${_formatSkills(userData['skills'])??''}",
                                        style: textBlack(),
                                      ),
                                      Text(
                                        "${userData['sub_district'??'']}, ${userData['district']??''}",
                                        style: textBlack(),
                                      ),
                                      Divider(),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(10))),
                                              child: Text(
                                                "Add Story",style: textBlack(),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => StoryPost()),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white70,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(10))),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "Edit Profile",style: textBlack(),
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdateUserProfile()),
                                                  );
                                                },
                                              ))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )),
              Expanded(child: Container(
               child: Column(
                 children: [
                   Container(
                     height: 50,
                     color: Colors.blue,
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         TextButton(

                           onPressed: (){
                             setState(() {
                               pageController!.jumpToPage(0);
                             });
                           },child: Text("Post",style: textWhite(),),),
                         TextButton(

                           onPressed: (){
                             setState(() {
                               pageController!.jumpToPage(1);
                             });
                           },child: Text("Events",style: textWhite(),)),
                         TextButton(

                           onPressed: (){
                             setState(() {
                               pageController!.jumpToPage(2);
                             });
                           },child: Text("Bloods",style: textWhite(),),)
                       ],
                     ),
                   ),
                   Expanded(child: PageView(
                     controller: pageController,
                     children: [
                       UserStoriesScreen(),
                       PostedEvents(),
                       PostedBloodPost(),
                     ],
                    )
                   ),

                 ],
               ),
              ))
            ],
          ),
        ),
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
