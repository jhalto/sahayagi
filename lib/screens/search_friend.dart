import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';
import '../helpers/notification_helper.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({Key? key}) : super(key: key);

  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  late Stream<QuerySnapshot> usersStream;
  final NotificationHelper _notificationHelper = NotificationHelper();

  @override
  void initState() {
    super.initState();
    usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentReference targetUserRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);

      DocumentSnapshot targetUserDoc = await targetUserRef.get();
      List<dynamic> friendRequests = targetUserDoc['friendRequests'] ?? [];

      if (friendRequests.contains(currentUser.uid)) {
        // Cancel friend request
        await targetUserRef.update({
          'friendRequests': FieldValue.arrayRemove([currentUser.uid])
        });
      } else {
        // Send friend request
        await targetUserRef.update({
          'friendRequests': FieldValue.arrayUnion([currentUser.uid])
        });

        // Send notification
        if (targetUserDoc.exists && targetUserDoc['device_token'] != null) {
          String token = targetUserDoc['device_token'];
          String senderName = currentUser.displayName ?? 'Someone';
          await _notificationHelper.sendPushNotification(
            token,
            'New Friend Request',
            '$senderName has sent you a friend request',
          );
        }
      }
    }
  }

  Future<void> respondToFriendRequest(String senderUserId, bool accept) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentReference currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      DocumentReference senderUserRef = FirebaseFirestore.instance.collection('users').doc(senderUserId);

      if (accept) {
        await currentUserRef.update({
          'friends': FieldValue.arrayUnion([senderUserId])
        });

        await senderUserRef.update({
          'friends': FieldValue.arrayUnion([currentUser.uid])
        });
      }

      await currentUserRef.update({
        'friendRequests': FieldValue.arrayRemove([senderUserId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Friend Requests', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser == null) {
            return Center(child: Text('User not logged in'));
          }

          List<DocumentSnapshot> users = snapshot.data!.docs.where((doc) => doc.id != currentUser.uid).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              DocumentSnapshot userDoc = users[index];
              Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

              List<dynamic> friends = userData['friends'] ?? [];
              List<dynamic> friendRequests = userData['friendRequests'] ?? [];

              bool isFriend = friends.contains(currentUser.uid);
              bool isRequested = friendRequests.contains(currentUser.uid);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: userData['profilePic'] != null && userData['profilePic'].isNotEmpty
                      ? NetworkImage(userData['profilePic'])
                      : AssetImage('lib/images/default_user_image.jpg') as ImageProvider,
                ),
                title: Text(userData['name'] ?? 'Unknown',style: texStyle(),),
                // subtitle: Text(userData['email'] ?? 'Unknown',style: texStyle(),),
                trailing: isFriend
                    ? Text('Friend',style: texStyle(),)
                    : isRequested
                    ? ElevatedButton(
                  onPressed: () {
                    sendFriendRequest(userDoc.id);
                  },
                  child: Text('Cancel Request',),
                )
                    : ElevatedButton(
                  onPressed: () {
                    sendFriendRequest(userDoc.id);
                  },
                  child: Text('Add Friend'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}