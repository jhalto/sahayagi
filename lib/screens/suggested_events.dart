import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/applied_events.dart';
import 'package:sahayagi/screens/event_post.dart';
import 'package:sahayagi/widget/common_widget.dart'; // Assuming this is where appFontStyle is defined

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

  Future<void> _registerForEvent(String eventId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      // Adding application details to the 'applications' sub-collection in the specific event document
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('applications')
          .doc(user.uid)
          .set({
        'user_id': user.uid,
        'name': user.displayName ?? 'Unknown', // assuming displayName is set
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Optionally, you can add a reference to this event in the user's document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('applied_events')
          .doc(eventId)
          .set({
        'event_id': eventId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully applied for the event')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to apply for the event: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Suggested Events", style: appFontStyle(25, texColorLight)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AppliedEvents()));
            },
            icon: Icon(Icons.app_registration_rounded),
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
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> eventSnapshot) {
              if (eventSnapshot.hasError) {
                return Center(child: Text('Something went wrong: ${eventSnapshot.error}'));
              }

              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!eventSnapshot.hasData || eventSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No matching events found'));
              }

              return ListView(
                padding: EdgeInsets.all(8.0),
                children: eventSnapshot.data!.docs.map((DocumentSnapshot document) {
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
                            ElevatedButton(
                              onPressed: () {
                                _registerForEvent(document.id);
                              },
                              child: Text("Apply"),
                            )
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