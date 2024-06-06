import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/applied_events.dart';
import 'package:sahayagi/widget/common_widget.dart'; // Assuming this is where appFontStyle is defined

class AllEvents extends StatefulWidget {
  const AllEvents({Key? key});

  @override
  State<AllEvents> createState() => _AllEventsState();
}

class _AllEventsState extends State<AllEvents> {
  String? _userSkill;
  String? _userDistrict;
  late Future<void> _fetchUserDetailsFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserDetailsFuture = _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      setState(() {
        _userSkill = userDoc['skill'];
        _userDistrict = userDoc['district'];
      });
    } else {
      throw Exception("User document not found");
    }
  }

  Future<List<DocumentSnapshot>> _getAppliedEvents() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applied_events')
        .get();

    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> _getEventsBySkill() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('skill', isEqualTo: _userSkill)
        .get();

    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> _getEventsByDistrict() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('district', isEqualTo: _userDistrict)
        .get();

    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> _getAllEvents() async {
    Set<String> seenEventIds = {};
    List<DocumentSnapshot> allEvents = [];

    // Fetch events by skill
    List<DocumentSnapshot> eventsBySkill = await _getEventsBySkill();
    for (var event in eventsBySkill) {
      if (seenEventIds.add(event.id)) {
        allEvents.add(event);
      }
    }

    // Fetch events by district
    List<DocumentSnapshot> eventsByDistrict = await _getEventsByDistrict();
    for (var event in eventsByDistrict) {
      if (seenEventIds.add(event.id)) {
        allEvents.add(event);
      }
    }

    // Fetch applied events to exclude them from the suggestions
    List<DocumentSnapshot> appliedEvents = await _getAppliedEvents();
    Set<String> appliedEventIds = appliedEvents.map((doc) => doc.id).toSet();

    // Exclude applied events from allEvents
    allEvents = allEvents.where((event) => !appliedEventIds.contains(event.id)).toList();

    return allEvents;
  }

  Future<void> _registerForEvent(String eventId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      // Fetch user document to get the user's name
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String userName = userDoc['name'] ?? 'Unknown';

      // Adding application details to the 'applications' sub-collection in the specific event document
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('applications')
          .doc(user.uid)
          .set({
        'user_id': user.uid,
        'name': userName, // Use the name fetched from Firestore
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
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getAllEvents(),
        builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          List<DocumentSnapshot> allEvents = snapshot.data ?? [];
          if (allEvents.isEmpty) {
            return Center(child: Text('No matching events found'));
          }

          return ListView.builder(
            itemCount: allEvents.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = allEvents[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Container(

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
            },
          );
        },
      ),
    );
  }
}