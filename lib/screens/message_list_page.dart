import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/manage_message.dart';
import 'package:sahayagi/widget/common_widget.dart';
import 'chat_screen.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({Key? key}) : super(key: key);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  late Stream<DocumentSnapshot> currentUserStream;

  @override
  void initState() {
    super.initState();
    User? currentUser = FirebaseAuth.instance.currentUser;
    currentUserStream = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots();
  }

  Future<void> refreshFriendList() async {
    setState(() {
      // This will rebuild the widget tree and trigger the StreamBuilder to fetch the latest data.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend List',style: TextStyle(color: Colors.white)),
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
          List<String> friends = List<String>.from(userData['friends'] ?? []);

          if (friends.isEmpty) {
            return Center(child: Text('No friends found',style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              String friendId = friends[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return ListTile(title: Text('User not found',style: TextStyle(color: Colors.white)));
                  }

                  Map<String, dynamic> friendData = snapshot.data!.data() as Map<String, dynamic>;

                  String profilePic = friendData['profilePic'] ?? ''; // Provide a default value
                  String name = friendData['name'] ?? 'Unknown'; // Provide a default value
                  String email = friendData['email'] ?? 'No email'; // Provide a default value

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                      child: profilePic.isEmpty ? Icon(Icons.person) : null,
                    ),
                    title: Text(name,style: texStyle(),),
                    subtitle: Text(email,style: texStyle(),),
                    onLongPress: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ManageMessagesPage(),));
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(friendId: friendId, friendName: name),
                        ),
                      ).then((value) {
                        if (value == true) {
                          refreshFriendList();
                        }
                      });
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