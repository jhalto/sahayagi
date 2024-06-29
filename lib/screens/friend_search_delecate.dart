import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';
import 'chat_screen.dart';

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

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                child: profilePic.isEmpty ? Icon(Icons.person) : null,
              ),
              title: Text(name, style: texStyle()),
              subtitle: Text(email, style: texStyle()),
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
            );
          },
        );
      },
    );
  }
}