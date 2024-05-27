import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/event_post.dart';
import '../widget/common_widget.dart'; // Assuming this is where appFontStyle is defined

class AllEvents extends StatefulWidget {
  const AllEvents({super.key});

  @override
  State<AllEvents> createState() => _AllEventsState();
}

class _AllEventsState extends State<AllEvents> {
  String? _userSkill;
  late Future<void> _fetchUserSkillFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserSkillFuture = _fetchUserSkill();
  }

  Future<void> _fetchUserSkill() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      _userSkill = userDoc['skill'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Suggested Events"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EventPost()));
            },
            icon: Icon(Icons.add_card_outlined),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _fetchUserSkillFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .where('skill', isEqualTo: _userSkill)
                .orderBy('skill', descending: true)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No matching events found'));
              }

              return ListView(
                padding: EdgeInsets.all(8.0),
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return Container(
                    height: 350,
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Posted by: ${data['user_name'] ?? 'Unknown'}', style: appFontStyle(15, texColorDark, FontWeight.bold)),
                            SizedBox(height: 10),
                            Text(data['title'] ?? 'Empty', style: appFontStyle(20, texColorDark, FontWeight.bold)),
                            SizedBox(height: 10),
                            Text(data['description'] ?? 'No description', style: appFontStyle(15)),
                            SizedBox(height: 10),
                            Text('Event Type: ${data['event_type'] ?? 'N/A'}', style: appFontStyle(15)),
                            SizedBox(height: 10),
                            Text('Skill: ${data['skill'] ?? 'N/A'}', style: appFontStyle(15)),
                            SizedBox(height: 10),
                            Text('Location:', style: appFontStyle(15, texColorDark, FontWeight.bold)),
                            Text('Post Office: ${data['post_office'] ?? 'N/A'}', style: appFontStyle(15)),
                            Text('Sub District: ${data['sub_district'] ?? 'N/A'}', style: appFontStyle(15)),
                            Text('District: ${data['district'] ?? 'N/A'}', style: appFontStyle(15)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}