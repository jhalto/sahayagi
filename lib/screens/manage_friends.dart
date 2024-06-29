import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';
import 'chat_screen.dart';

class ManageFriendsPage extends StatefulWidget {
  const ManageFriendsPage({Key? key}) : super(key: key);

  @override
  _ManageFriendsPageState createState() => _ManageFriendsPageState();
}

class _ManageFriendsPageState extends State<ManageFriendsPage> {
  late Stream<DocumentSnapshot> currentUserStream;

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    currentUserStream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .snapshots();
  }

  Future<void> removeFriend(String friendId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String currentUserId = currentUser.uid;
    DocumentReference currentUserRef =
    FirebaseFirestore.instance.collection('users').doc(currentUserId);
    DocumentReference friendUserRef =
    FirebaseFirestore.instance.collection('users').doc(friendId);

    await currentUserRef.update({
      'friends': FieldValue.arrayRemove([friendId])
    });

    await friendUserRef.update({
      'friends': FieldValue.arrayRemove([currentUserId])
    });

    setState(() {});
  }

  void navigateToChatScreen(String friendId, String friendName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(friendId: friendId, friendName: friendName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Friends'),
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

          Map<String, dynamic> userData =
          snapshot.data!.data() as Map<String, dynamic>;
          List<String> friends =
          List<String>.from(userData['friends'] ?? []);

          if (friends.isEmpty) {
            return Center(child: Text('No friends found'));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              String friendId = friends[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(friendId)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(title: Text('User not found'));
                  }

                  Map<String, dynamic> friendData =
                  snapshot.data!.data() as Map<String, dynamic>;

                  String profilePic = friendData['profilePic'] ?? '';
                  String name = friendData['name'] ?? 'Unknown';
                  String email = friendData['email'] ?? 'No email';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty
                          ? NetworkImage(profilePic)
                          : null,
                      child: profilePic.isEmpty
                          ? Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      name,
                      style: texStyle(),
                    ),
                    subtitle: Text(
                      email,
                      style: texStyle(),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        removeFriend(friendId);
                      },
                    ),
                    onTap: () {
                      navigateToChatScreen(friendId, name);
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