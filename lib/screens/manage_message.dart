import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';
import 'chat_screen.dart';

class ManageMessagesPage extends StatefulWidget {
  const ManageMessagesPage({Key? key}) : super(key: key);

  @override
  _ManageMessagesPageState createState() => _ManageMessagesPageState();
}

class _ManageMessagesPageState extends State<ManageMessagesPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getConversationsStream() {
    return _firestore.collection('messages').snapshots();
  }

  void _showFriendSearch() {
    showSearch(
      context: context,
      delegate: _FriendSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Messages', style: texStyle()),
        actions: [
          IconButton(
            onPressed: _showFriendSearch,
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getConversationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No conversations found'));
          }

          final messages = snapshot.data!.docs;
          final friendIds = messages
              .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final deletedFor = data['deletedFor'] ?? [];
            return !deletedFor.contains(currentUser!.uid);
          })
              .map((doc) => doc['senderId'] == currentUser!.uid ? doc['receiverId'] as String : doc['senderId'] as String)
              .toSet()
              .toList();

          return ListView.builder(
            itemCount: friendIds.length,
            itemBuilder: (context, index) {
              final friendId = friendIds[index];

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(friendId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return SizedBox.shrink(); // Don't show anything if the user is deleted
                  }

                  final friendData = snapshot.data!.data() as Map<String, dynamic>;
                  final profilePic = friendData['profilePic'] ?? '';
                  final name = friendData['name'] ?? 'Unknown';
                  final email = friendData['email'] ?? 'No email';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                      child: profilePic.isEmpty ? Icon(Icons.person) : null,
                    ),
                    title: Text(name,),
                    subtitle: Text(email,),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(friendId: friendId, friendName: name),
                        ),
                      );
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

class _FriendSearchDelegate extends SearchDelegate<String> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  String get searchFieldLabel => 'Search for friends...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Close search and return to previous screen
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No users found'));
        }

        final users = snapshot.data!.docs;
        final filteredUsers = users.where((user) {
          final userData = user.data() as Map<String, dynamic>;
          final name = userData['name'] ?? '';
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final userData = filteredUsers[index].data() as Map<String, dynamic>;
            final userId = filteredUsers[index].id;
            final name = userData['name'] ?? 'Unknown';
            final email = userData['email'] ?? 'No email';
            final profilePic = userData['profilePic'] ?? '';

            return GestureDetector(
              onLongPress: (){},
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                  child: profilePic.isEmpty ? Icon(Icons.person) : null,
                ),
                title: Text(name),
                subtitle: Text(email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(friendId: userId, friendName: name),
                    ),
                  ).then((value) {
                    if (value == true) {
                      // Close the search and return to previous screen
                      close(context, '');
                    }
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}