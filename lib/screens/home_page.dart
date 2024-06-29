import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/manage_message.dart';
import 'package:sahayagi/screens/message_list_page.dart';
import 'package:sahayagi/screens/post_option.dart';
import 'package:share/share.dart';

import '../widget/common_widget.dart';
import 'app_drawer.dart';
import 'chat_screen.dart';
import 'comment_screen.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _storyStream = FirebaseFirestore.instance
      .collection('stories')
      .orderBy('timestamp', descending: true)
      .snapshots();

  void _likePost(DocumentSnapshot document) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(document.reference);
      int currentLikes = freshSnap['likes'] ?? 0;
      transaction.update(document.reference, {'likes': currentLikes + 1});
    });
  }

  void _commentOnPost(DocumentSnapshot document) {
    // Navigate to the comment screen (you need to create this screen)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentScreen(postId: document.id),
      ),
    );
  }

  void _sharePost(String title, String content) {
    Share.share('$title\n\n$content');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        toolbarHeight: 65,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Sahayagi",
              style: appFontStyle(30, texColorLight, FontWeight.bold),
            ),
            Text(
              "Volunteer BD",
              style: appFontStyle(
                  15, texColorLight, FontWeight.w500, FontStyle.italic),
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PostOption()));
            },
            icon: Icon(Icons.add_card_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManageMessagesPage()));
            },
            icon: Icon(Icons.message),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _storyStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No stories found'));
          }

          return ListView(
            padding: EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              return Container(
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Posted by: ${data['user_name'] ?? 'Unknown'}',
                            style: appFontStyle(
                                15, Colors.black, FontWeight.w600
                            )),
                        SizedBox(height: 10),
                        Text(data['title'] ?? 'No Title',
                            style: appFontStyle(
                                20, Colors.black, FontWeight.bold
                            )),
                        SizedBox(height: 10),
                        if (data['image_url'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(data['image_url']),
                          ),
                        SizedBox(height: 10),
                        Text(data['content'] ?? 'No Content',
                            style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text(
                          'Posted on: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : 'Unknown'}',
                          style: appFontStyle(12, Colors.grey),
                        ),
                        Divider(thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () => _likePost(document),
                              icon: Icon(Icons.thumb_up_alt_outlined),
                            ),
                            IconButton(
                              onPressed: () => _commentOnPost(document),
                              icon: Icon(Icons.comment_outlined),
                            ),
                            IconButton(
                              onPressed: () => _sharePost(data['title'], data['content']),
                              icon: Icon(Icons.share_outlined),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}