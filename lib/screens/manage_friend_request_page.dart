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
        title: Text('Friend Requests',style: texStyle()),
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

          return ListView.builder(
            itemCount: friendRequests.length,
            itemBuilder: (context, index) {
              String requestId = friendRequests[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(requestId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(title: Text('User not found'));
                  }

                  Map<String, dynamic> requestUserData = snapshot.data!.data() as Map<String, dynamic>;

                  String profilePic = requestUserData['profilePic'] ?? ''; // Provide a default value
                  String name = requestUserData['name'] ?? 'Unknown'; // Provide a default value
                  String email = requestUserData['email'] ?? 'No email'; // Provide a default value

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                      child: profilePic.isEmpty ? Icon(Icons.person) : null,
                    ),
                    title: Text(name,style: texStyle(),),
                    subtitle: Text(email,style: texStyle(),),
                    onTap: () async {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendRequestDetailPage(
                            requestId: requestId,
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
}