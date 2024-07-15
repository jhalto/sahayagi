import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/chat_screen.dart';
import 'package:sahayagi/screens/other_user_blood_posts.dart';
import 'package:sahayagi/screens/other_user_friend.dart';
import 'package:sahayagi/screens/others_user_events.dart';
import 'package:sahayagi/screens/others_user_story.dart';

import '../helpers/notification_helper.dart';
import '../widget/common_widget.dart';

class OtherUserProfileDetail extends StatefulWidget {
  final String userId;

  OtherUserProfileDetail({required this.userId});

  @override
  _OtherUserProfileDetailState createState() => _OtherUserProfileDetailState();
}

class _OtherUserProfileDetailState extends State<OtherUserProfileDetail> {
  late Stream<DocumentSnapshot> otherUserStream;
  PageController? pageController;
  int currentIndex = 0;
  final NotificationHelper _notificationHelper = NotificationHelper();

  @override
  void initState() {
    super.initState();
    otherUserStream = FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots();
    pageController = PageController(
      initialPage: currentIndex,
    );
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentReference targetUserRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);
      DocumentReference currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      DocumentSnapshot targetUserDoc = await targetUserRef.get();
      if (targetUserDoc.exists) {
        Map<String, dynamic>? targetUserData = targetUserDoc.data() as Map<String, dynamic>?;

        if (targetUserData != null) {
          List<dynamic> friendRequests = targetUserData.containsKey('friendRequests')
              ? targetUserData['friendRequests']
              : [];
          List<dynamic> incomingFriendRequests = targetUserData.containsKey('incomingFriendRequests')
              ? targetUserData['incomingFriendRequests']
              : [];

          if (friendRequests.contains(currentUser.uid)) {
            // Cancel friend request
            await targetUserRef.update({
              'friendRequests': FieldValue.arrayRemove([currentUser.uid])
            });
            await currentUserRef.update({
              'incomingFriendRequests': FieldValue.arrayRemove([targetUserId])
            });
          } else {
            // Send friend request
            await targetUserRef.update({
              'friendRequests': FieldValue.arrayUnion([currentUser.uid])
            });
            await currentUserRef.update({
              'incomingFriendRequests': FieldValue.arrayUnion([targetUserId])
            });

            // Send notification
            if (targetUserData.containsKey('device_token') && targetUserData['device_token'] != null) {
              String token = targetUserData['device_token'];
              String senderName = currentUser.displayName ?? 'Someone';
              await _notificationHelper.sendPushNotification(
                token,
                'New Friend Request',
                '$senderName has sent you a friend request',
              );
            }
          }

          // Refresh the state to update UI
          setState(() {});
        }
      }
    }
  }

  Future<void> respondToFriendRequest(String targetUserId, bool accept) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentReference targetUserRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);
      DocumentReference currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      if (accept) {
        // Accept friend request
        await currentUserRef.update({
          'friends': FieldValue.arrayUnion([targetUserId])
        });
        await targetUserRef.update({
          'friends': FieldValue.arrayUnion([currentUser.uid])
        });
      }

      // Remove friend request
      await currentUserRef.update({
        'incomingFriendRequests': FieldValue.arrayRemove([targetUserId])
      });
      await targetUserRef.update({
        'friendRequests': FieldValue.arrayRemove([currentUser.uid])
      });

      // Refresh the state to update UI
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: otherUserStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
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

                  List<dynamic> friends = userData['friends'] ?? [];
                  List<dynamic> friendRequests = userData['friendRequests'] ?? [];
                  List<dynamic> incomingFriendRequests = userData['incomingFriendRequests'] ?? [];
                  bool isFriend = friends.contains(FirebaseAuth.instance.currentUser!.uid);
                  bool isRequested = friendRequests.contains(FirebaseAuth.instance.currentUser!.uid);
                  bool isIncomingRequest = incomingFriendRequests.contains(FirebaseAuth.instance.currentUser!.uid);

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
                                  fit: BoxFit.fill,
                                  image: NetworkImage("${userData['coverPhotoUrl'] ?? ''}"),
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 5,
                                left: 15,
                                child: CircleAvatar(
                                  maxRadius: 50,
                                  backgroundImage:
                                  NetworkImage("${userData['photoUrl'] ?? ''}"),
                                )),
                            Positioned(
                                top: 210,
                                left: 140,
                                child: Container(
                                    width: 250, child: Text(userData['bio'] ?? ''))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${userData['name'] ?? ''}", style: textBlackBold(22)),
                              Text("${_formatSkills(userData['skills']) ?? ''}",
                                  style: textBlack()),
                              Text(
                                "${userData['sub_district'] ?? ''}, ${userData['district'] ?? ''}",
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
                                              borderRadius: BorderRadius.circular(10))),
                                      child: Text(
                                        "Message",
                                        style: textBlack(),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatScreen(
                                                  friendId: widget.userId,
                                                  friendName: userData['name'] ?? '')),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  if (isFriend)
                                    Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10))),
                                          child: Row(
                                            children: [
                                              Icon(Icons.check),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Friend",
                                                style: textBlack(),
                                              ),
                                            ],
                                          ),
                                          onPressed: () {
                                             //crete function here for remove as friend or block
                                          },
                                        ))
                                  else if (isIncomingRequest)
                                    Expanded(
                                        child: Column(
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10))),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.check),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Confirm Request",
                                                    style: textBlack(),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () {
                                                respondToFriendRequest(widget.userId, true);
                                              },
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10))),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.cancel),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    "Cancel Request",
                                                    style: textBlack(),
                                                  ),
                                                ],
                                              ),
                                              onPressed: () {
                                                respondToFriendRequest(widget.userId, false);
                                              },
                                            ),
                                          ],
                                        ))
                                  else if (isRequested)
                                      Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white70,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10))),
                                            child: Row(
                                              children: [
                                                Icon(Icons.person_remove),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Cancel Request",
                                                    style: textBlack(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              sendFriendRequest(widget.userId);
                                            },
                                          ))
                                    else
                                      Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white70,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10))),
                                            child: Row(
                                              children: [
                                                Icon(Icons.person_add),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "Add Friend",
                                                    style: textBlack(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              sendFriendRequest(widget.userId);
                                            },
                                          )),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OtherUserFriendsPage(userId: widget.userId),));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Friends", style: textBlackBold(16),),
                ),
              ),

              Container(
                height: 50,
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(0, "Stories"),
                    _buildNavButton(1, "Events"),
                    _buildNavButton(2, "Blood Posts"),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height - 300, // Adjust this value as needed
                child: PageView(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  children: [
                    OtherUserStoriesScreen(userId: widget.userId),
                    OtherUserEventsScreen(userId: widget.userId),
                    OtherUserBloodPosts(userId: widget.userId),
                  ],
                ),
              ),
            ],
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
          color: currentIndex == index ? Colors.yellow : Colors.white,
          fontWeight: currentIndex == index ? FontWeight.bold : FontWeight.normal,
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