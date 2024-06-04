import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';

class AppliedEvents extends StatefulWidget {
  const AppliedEvents({super.key});

  @override
  State<AppliedEvents> createState() => _AppliedEventsState();
}

class _AppliedEventsState extends State<AppliedEvents> {
  Future<List<Map<String, dynamic>>> _fetchAppliedEvents() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    QuerySnapshot appliedEventsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applied_events')
        .get();

    List<Map<String, dynamic>> appliedEventsDocs = [];
    for (var doc in appliedEventsSnapshot.docs) {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(doc.id)
          .get();

      if (eventDoc.exists && eventDoc.data() != null) {
        appliedEventsDocs.add({
          'document': eventDoc,
          'appliedEventId': doc.id,
        });
      }
    }

    return appliedEventsDocs;
  }

  Future<void> _removeApplication(BuildContext context, String eventId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('applied_events')
          .doc(eventId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application removed successfully')),
      );

      setState(() {}); // Refresh the list after removal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove application: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Applied Events", style: appFontStyle(25, texColorLight)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAppliedEvents(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No applied events found'));
          }

          return ListView(
            padding: EdgeInsets.all(8.0),
            children: snapshot.data!.map((Map<String, dynamic> data) {
              DocumentSnapshot document = data['document'];
              String appliedEventId = data['appliedEventId'];
              Map<String, dynamic>? eventData = document.data() as Map<String, dynamic>?;

              if (eventData == null) {
                return Container();
              }

              return Container(
                height: 350,
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Posted by: ${eventData['user_name'] ?? 'Unknown'}',
                          style: appFontStyle(15, texColorDark, FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          eventData['title'] ?? 'Empty',
                          style: appFontStyle(20, texColorDark, FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          eventData['description'] ?? 'No description',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Event Type: ${eventData['event_type'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Skill: ${eventData['skill'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Location:',
                          style: appFontStyle(15, texColorDark, FontWeight.bold),
                        ),
                        Text(
                          'Post Office: ${eventData['post_office'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        Text(
                          'Sub District: ${eventData['sub_district'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        Text(
                          'District: ${eventData['district'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            bool confirmRemove = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Remove Application'),
                                  content: Text('Are you sure you want to remove this application?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('Remove'),
                                    ),
                                  ],
                                );
                              },
                            ) ?? false;

                            if (confirmRemove) {
                              await _removeApplication(context, appliedEventId);
                            }
                          },
                          child: const Text("Remove Application"),
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