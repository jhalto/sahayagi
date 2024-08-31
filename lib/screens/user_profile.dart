import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/posted_blood_post.dart';
import 'package:sahayagi/screens/posted_events.dart';
import 'package:sahayagi/screens/update_profile.dart';
import 'package:sahayagi/screens/user_story.dart';
import '../helpers/helper.dart';
import '../widget/common_widget.dart';
import 'event_search_delecate.dart';
import 'manage_friend_request_page.dart';
import 'manage_friends.dart';

class UserProfileDetail extends StatefulWidget {
  @override
  _UserProfileDetailState createState() => _UserProfileDetailState();
}

class _UserProfileDetailState extends State<UserProfileDetail> {
  late Stream<DocumentSnapshot> currentUserStream;
  final User? user = FirebaseAuth.instance.currentUser;
  PageController? pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    currentUserStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots();
    pageController = PageController(initialPage: currentIndex);
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: EventSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: _showSearch,
              icon: Icon(Icons.search),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: currentUserStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                      return Center(child: Text('No user data available', style: TextStyle(color: Colors.black)));
                    }

                    var userData = snapshot.data!.data() as Map<String, dynamic>?;
                    if (userData == null) {
                      return Center(child: Text('User data is empty', style: TextStyle(color: Colors.black)));
                    }

                    return Column(
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
                                    fit: BoxFit.cover,
                                    image: NetworkImage(userData['coverPhotoUrl'] ?? 'https://via.placeholder.com/400x200'),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 15,
                                child: CircleAvatar(
                                  maxRadius: 50,
                                  backgroundImage: NetworkImage(userData['photoUrl'] ?? 'https://via.placeholder.com/100x100'),
                                ),
                              ),
                              Positioned(
                                top: 210,
                                left: 140,
                                child: Container(
                                  width: 250,
                                  child: Text(userData['bio'] ?? 'No bio available'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userData['name'] ?? 'No name', style: textBlackBold(22)),
                              Text(_formatSkills(userData['skills']), style: textBlack()),
                              Text("${userData['sub_district'] ?? 'Unknown'}, ${userData['district'] ?? 'Unknown'}", style: textBlack()),
                              Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text("Friend Request", style: textBlack()),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ManageFriendRequestsPage()));
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white70,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 5),
                                          Text("Edit Profile", style: textBlack()),
                                        ],
                                      ),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateUserProfile()));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ManageFriendsPage()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Friends", style: textBlackBold(16)),
                  ),
                ),
                Container(
                  height: 50,
                  color: Colors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavButton(0, "Post"),
                      _buildNavButton(1, "Events"),
                      _buildNavButton(2, "Bloods"),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 300,
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    children: [
                      UserStoriesScreen(),
                      PostedEvents(),
                      PostedBloodPost(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(int index, String title) {
    return TextButton(
      onPressed: () {
        setState(() {
          currentIndex = index;
          pageController!.jumpToPage(index);
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: currentIndex == index ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatSkills(List<dynamic>? skills) {
    if (skills == null || skills.isEmpty) {
      return 'No skills listed';
    }
    return skills.join(', ');
  }
}