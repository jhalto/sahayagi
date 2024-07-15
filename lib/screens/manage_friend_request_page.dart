import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';

import 'friend_request_details_page.dart';

class ManageFriendRequestsPage extends StatefulWidget {
  const ManageFriendRequestsPage({Key? key}) : super(key: key);

  @override
  _ManageFriendRequestsPageState createState() => _ManageFriendRequestsPageState();
}

class _ManageFriendRequestsPageState extends State<ManageFriendRequestsPage> {
  late Stream<DocumentSnapshot> currentUserStream;

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    currentUserStream = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests', style: texStyle()),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: currentUserStream,
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User document not found'));
          }

          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
          List<String> friendRequests = List<String>.from(userData['friendRequests'] ?? []);

          if (friendRequests.isEmpty) {
            return Center(child: Text('No friend requests'));
          }

          return FutureBuilder<List<DocumentSnapshot>>(
            future: _getValidFriendRequests(friendRequests),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No valid friend requests'));
              }

              List<DocumentSnapshot> validRequests = snapshot.data!;

              return ListView.builder(
                itemCount: validRequests.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot userDoc = validRequests[index];
                  Map<String, dynamic> requestUserData = userDoc.data() as Map<String, dynamic>;

                  String profilePic = requestUserData['profilePic'] ?? ''; // Provide a default value
                  String name = requestUserData['name'] ?? 'Unknown'; // Provide a default value
                  String email = requestUserData['email'] ?? 'No email'; // Provide a default value

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                      child: profilePic.isEmpty ? Icon(Icons.person) : null,
                    ),
                    title: Text(name),
                    subtitle: Text(email),
                    onTap: () async {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendRequestDetailPage(
                            requestId: userDoc.id,
                            currentUserId: FirebaseAuth.instance.currentUser!.uid,
                          ),
                        ),
                      );

                      if (result == true) {
                        setState(() {});
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _getValidFriendRequests(List<String> friendRequests) async {
    List<DocumentSnapshot> validRequests = [];

    for (String requestId in friendRequests) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(requestId).get();
      if (userDoc.exists) {
        validRequests.add(userDoc);
      }
    }

    return validRequests;
  }
}