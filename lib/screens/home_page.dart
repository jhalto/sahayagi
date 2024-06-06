import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/post.dart';
import 'package:sahayagi/screens/sign_in.dart';
import '../models/events_model.dart';
import '../widget/common_widget.dart';
import 'event_post.dart';
import 'message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> registerEvent() async {
   }

  final Stream<QuerySnapshot> _eventStream = FirebaseFirestore.instance
      .collection('events')
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
          // IconButton(onPressed: (){
          //          Navigator.push(context, MaterialPageRoute(builder: (context) => const Messages(),));
          // }, icon: const Icon(Icons.messenger_outline_outlined)),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PostOption()));
            },
            icon: Icon(Icons.add_card_outlined),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events found'));
          }

          return ListView(
            padding: EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Container(
                height: 350,
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
                        Text(data['title'] ?? 'Empty',
                            style: appFontStyle(
                              20,
                            )),
                        SizedBox(height: 10),
                        Text(data['description'] ?? 'No description',
                            style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text('Event Type: ${data['event_type'] ?? 'N/A'}',
                            style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text('Skill: ${data['skill'] ?? 'N/A'}',
                            style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text('Location:',
                            style: appFontStyle(
                              15,
                            )),
                        Text('Post Office: ${data['post_office'] ?? 'N/A'}',
                            style: appFontStyle(15)),
                        Text('Sub District: ${data['sub_district'] ?? 'N/A'}',
                            style: appFontStyle(15)),
                        Text('District: ${data['district'] ?? 'N/A'}',
                            style: appFontStyle(15)),
                        ElevatedButton(onPressed: (){

                        }, child: Text("Apply")),
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
