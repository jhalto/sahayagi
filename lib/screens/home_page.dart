import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/chat_screen.dart';
import 'package:sahayagi/screens/post_option.dart';
import '../widget/common_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _storyStream = FirebaseFirestore.instance
      .collection('stories')
      .orderBy('timestamp', descending: true)
      .snapshots();

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
                  MaterialPageRoute(builder: (context) => ChatScreen()));
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Posted by: ${data['user_name'] ?? 'Unknown'}',
                            style: appFontStyle(
                              15,
                            )),
                        SizedBox(height: 10),
                        Text(data['title'] ?? 'No Title',
                            style: appFontStyle(
                              20,
                            )),
                        SizedBox(height: 10),
                        if (data['image_url'] != null)
                          Image.network(data['image_url']),
                        SizedBox(height: 10),
                        Text(data['content'] ?? 'No Content',
                            style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text(
                          'Posted on: ${data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString() : 'Unknown'}',
                          style: appFontStyle(12, Colors.grey),
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