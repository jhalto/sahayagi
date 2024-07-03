import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/edit_story_screen.dart';
import 'package:sahayagi/screens/manage_message.dart';
import 'package:sahayagi/screens/story_post.dart';
import 'package:sahayagi/widget/common_widget.dart';

import 'message_list_page.dart';

class UserStoriesScreen extends StatefulWidget {
  const UserStoriesScreen({Key? key}) : super(key: key);

  @override
  State<UserStoriesScreen> createState() => _UserStoriesScreenState();
}

class _UserStoriesScreenState extends State<UserStoriesScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Stream<List<DocumentSnapshot>> _fetchUserStories() {
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('stories')
        .where('user_id', isEqualTo: user!.uid)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs);
  }

  Future<void> _deleteStory(String storyId) async {
    try {
      await FirebaseFirestore.instance.collection('stories').doc(storyId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Story deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete story: $e')),
      );
    }
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
            return Center(child: Text('No stories found',style: texStyle(),));
          }

          return ListView.builder(
            shrinkWrap: true,

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
                        Image.network(data['image_url'],height: 240,width:double.infinity,fit: BoxFit.fill,),
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
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditStoryScreen(storyId: document.id, data: data),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              bool confirmDelete = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Delete Story'),
                                    content: Text('Are you sure you want to delete this story?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              ) ?? false;

                              if (confirmDelete) {
                                await _deleteStory(document.id);
                              }
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
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => StoryPost(),));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}