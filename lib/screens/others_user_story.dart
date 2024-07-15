import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/edit_story_screen.dart';
import 'package:sahayagi/screens/story_post.dart';
import 'package:sahayagi/widget/common_widget.dart';

class OtherUserStoriesScreen extends StatelessWidget {
  final String userId;

  OtherUserStoriesScreen({required this.userId});

  Stream<List<DocumentSnapshot>> _fetchUserStories() {
    return FirebaseFirestore.instance
        .collection('stories')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _fetchUserStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          List<DocumentSnapshot> stories = snapshot.data ?? [];
          if (stories.isEmpty) {
            return Center(child: Text('No stories found', style: texStyle()));
          }

          return ListView.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = stories[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'No Title',
                        style: appFontStyle(20, texColorDark, FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      if (data['image_url'] != null)
                        Image.network(data['image_url'], height: 240, width: double.infinity, fit: BoxFit.fill),
                      SizedBox(height: 10),
                      Text(
                        data['content'] ?? 'No Content',
                        style: appFontStyle(15),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Posted on: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : 'Unknown'}',
                        style: appFontStyle(12, Colors.grey),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(Icons.app_registration),
                            onPressed: () {

                            },
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => StoryPost()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
