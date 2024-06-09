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
  Stream<List<DocumentSnapshot>> _fetchAppliedEvents() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applied_events')
        .snapshots()
        .asyncMap((QuerySnapshot appliedEventsSnapshot) async {
      List<DocumentSnapshot> appliedEventsDocs = [];
      for (var doc in appliedEventsSnapshot.docs) {
        DocumentSnapshot eventDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(doc.id)
            .get();

        if (eventDoc.exists) {
          appliedEventsDocs.add(eventDoc);
        }
      }
      return appliedEventsDocs;
    });
  }

  Future<void> _removeApplication(String eventId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('applied_events')
          .doc(eventId)
          .delete();

      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('applications')
          .doc(user.uid)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application removed successfully')),
      );
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
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _fetchAppliedEvents(),
        builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          List<DocumentSnapshot> appliedEvents = snapshot.data ?? [];
          if (appliedEvents.isEmpty) {
            return Center(child: Text('No applied events found'));
          }

          return ListView.builder(
            itemCount: appliedEvents.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = appliedEvents[index];
              Map<String, dynamic> eventData = document.data() as Map<String, dynamic>;

              List<String> skills = List<String>.from(eventData['skills'] ?? []);

              return Container(
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
                          'Skills Required: ${skills.join(', ')}',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Location:',
                          style: appFontStyle(15, texColorDark, FontWeight.bold),
                        ),
                        Text(
                          'Sub District: ${eventData['sub_district'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        Text(
                          'District: ${eventData['district'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        Text(
                          'Location Details: ${eventData['location_details'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
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
                              await _removeApplication(document.id);
                            }
                          },
                          child: const Text("Remove Application"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}