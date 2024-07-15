import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OtherUserFriendsPage extends StatefulWidget {
  final String userId;

  const OtherUserFriendsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _OtherUserFriendsPageState createState() => _OtherUserFriendsPageState();
}

class _OtherUserFriendsPageState extends State<OtherUserFriendsPage> {
  late Stream<DocumentSnapshot> userStream;

  @override
  void initState() {
    super.initState();
    userStream = FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userStream,
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
          List<String> friends = List<String>.from(userData['friends'] ?? []);

          if (friends.isEmpty) {
            return Center(child: Text('No friends found'));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              String friendId = friends[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(title: Text('User not found'));
                  }

                  Map<String, dynamic> friendData = snapshot.data!.data() as Map<String, dynamic>;

                  String profilePic = friendData['photoUrl'] ?? '';
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
                    title: Text(name),
                    subtitle: Text(email),
                    onTap: () {
                      // Handle tapping on a friend tile if needed
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