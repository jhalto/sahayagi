import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/event_detail_page.dart';
import 'package:sahayagi/screens/other_user_detail_page.dart';
import '../widget/common_widget.dart';

class EventSearchDelegate extends SearchDelegate<String> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  String get searchFieldLabel => 'Search for friends or events...';

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
    return Column(
      children: [
        Expanded(child: _buildUserResults(context)),
        Divider(),
        Expanded(child: _buildEventResults(context)),
      ],
    );
  }

  Widget _buildUserResults(BuildContext context) {
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
              title: Text(name, style: textBlackBold(16)),
              subtitle: Text(email, style: textBlack()),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtherUserProfileDetail(userId: userId),
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

  Widget _buildEventResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No events found'));
        }

        final events = snapshot.data!.docs;
        final filteredEvents = events.where((event) {
          final eventData = event.data() as Map<String, dynamic>;
          final skills = eventData['skills'] ?? [];
          if (skills is List) {
            return skills.any((skill) => skill.toString().toLowerCase().contains(query.toLowerCase()));
          }
          return false;
        }).toList();

        return ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final eventData = filteredEvents[index].data() as Map<String, dynamic>;
            final eventId = filteredEvents[index].id;
            final name = eventData['title'] ?? 'Unknown';
            final skills = eventData['skills'] ?? [];
            final skillString = (skills is List) ? skills.join(', ') : 'Unknown';
            final date = eventData['date'] ?? 'No date';

            return ListTile(
              leading: Icon(Icons.event),
              title: Text(name, style: textBlackBold(16)),
              subtitle: Text('$skillString - $date', style: textBlack()),
              onTap: () {
                // Navigate to the event details screen (implement this screen)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailsPage(eventId: eventId),
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