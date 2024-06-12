import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/applied_users_in_events.dart';
import 'package:sahayagi/screens/edit_posted_events.dart';

import '../widget/common_widget.dart';
import 'app_drawer.dart';

class PostedEvents extends StatefulWidget {
  const PostedEvents({super.key});

  @override
  State<PostedEvents> createState() => _PostedEventsState();
}

class _PostedEventsState extends State<PostedEvents> {
  late Future<void> _fetchUserEventsFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserEventsFuture = _fetchUserEvents();
  }

  Future<void> _fetchUserEvents() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
  }

  Future<void> _deleteEvent(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text("Posted Events", style: appFontStyle(25, texColorLight)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Add functionality for adding new events
            },
            icon: const Icon(Icons.add_card_outlined),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _fetchUserEventsFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          User? user = FirebaseAuth.instance.currentUser;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .where('user_id', isEqualTo: user!.uid)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> eventSnapshot) {
              if (eventSnapshot.hasError) {
                return Center(child: Text('Something went wrong: ${eventSnapshot.error}'));
              }

              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!eventSnapshot.hasData || eventSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No events posted by you'));
              }

              return ListView(
                padding: const EdgeInsets.all(8.0),
                children: eventSnapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  return _buildEventCard(context, data, document.id);
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Map<String, dynamic> data, String documentId) {
    String skills = (data['skills'] as List<dynamic>?)?.join(', ') ?? 'N/A';

    return Container(
      height: 370,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Posted by: ${data['user_name'] ?? 'Unknown'}', style: appFontStyle(15, texColorDark, FontWeight.bold)),
              const SizedBox(height: 10),
              Text(data['title'] ?? 'Empty', style: appFontStyle(20, texColorDark, FontWeight.bold)),
              const SizedBox(height: 10),
              Text(data['description'] ?? 'No description', style: appFontStyle(15)),
              const SizedBox(height: 10),
              Text('Event Type: ${data['event_type'] ?? 'N/A'}', style: appFontStyle(15)),
              const SizedBox(height: 10),
              Text("Needed Skill: ${skills}",style: appFontStyle(15,),),
              const SizedBox(height: 10),
              Text('Location:', style: appFontStyle(15, texColorDark, FontWeight.bold)),
              Text('Sub District: ${data['sub_district'] ?? 'N/A'}', style: appFontStyle(15)),
              Text('District: ${data['district'] ?? 'N/A'}', style: appFontStyle(15)),
              const Spacer(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPostedEvent(documentId: documentId),
                          ),
                        );
                      },
                      child: const Text("Edit"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete Event'),
                              content: Text('Are you sure you want to delete this event?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        ) ?? false;

                        if (confirmDelete) {
                          _deleteEvent(documentId);
                        }
                      },
                      style: ElevatedButton.styleFrom(),
                      child: const Text("Delete"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppliedUsersInEvent(eventId: documentId),
                          ),
                        );
                      },
                      child: const Text("View Applicants"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}