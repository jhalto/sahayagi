import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/applied_events.dart';
import 'package:sahayagi/screens/manage_message.dart';
import 'package:sahayagi/widget/common_widget.dart'; // Assuming this is where appFontStyle is defined
import '../helpers/notification_helper.dart';
import 'message_list_page.dart'; // Make sure this path is correct

class SugestedEvents extends StatefulWidget {
  const SugestedEvents({Key? key});

  @override
  State<SugestedEvents> createState() => _SugestedEventsState();
}

class _SugestedEventsState extends State<SugestedEvents> {
  List<String> _userSkills = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      setState(() {
        _userSkills = List<String>.from(userDoc['skills'] ?? []); // Assuming 'skills' is a list of strings
      });
    } else {
      throw Exception("User document not found");
    }
  }

  Stream<List<DocumentSnapshot>> _getEventsBySkills() {
    if (_userSkills.isEmpty) {
      return Stream.value([]);
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // Fetch applied events to exclude them from the suggestions
    Stream<List<DocumentSnapshot>> appliedEventsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applied_events')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);

    // Fetch all events that match the user's skills
    Stream<List<DocumentSnapshot>> eventsStream = FirebaseFirestore.instance
        .collection('events')
        .where('skills', arrayContainsAny: _userSkills) // Query events that match any of the user's skills
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);

    return eventsStream.asyncMap((allEvents) async {
      List<DocumentSnapshot> appliedEvents = await appliedEventsStream.first;
      Set<String> appliedEventIds = appliedEvents.map((doc) => doc.id).toSet();

      // Exclude applied events from allEvents
      allEvents = allEvents.where((event) => !appliedEventIds.contains(event.id)).toList();

      // Exclude events posted by the current user
      allEvents = allEvents.where((event) => event['user_id'] != user.uid).toList();

      return allEvents;
    });
  }

  Future<void> _registerForEvent(String eventId, String eventOwnerId) async {
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

      // Fetch event owner's device token
      DocumentSnapshot eventOwnerDoc = await FirebaseFirestore.instance.collection('users').doc(eventOwnerId).get();
      String? eventOwnerDeviceToken = eventOwnerDoc['device_token'];

      if (eventOwnerDeviceToken != null) {
        // Send notification to event owner
        NotificationHelper notificationHelper = NotificationHelper();
        await notificationHelper.sendPushNotification(
          eventOwnerDeviceToken,
          'New Application',
          'You have a new application for your event.',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully applied for the event')));

      // Trigger rebuild to refresh the events list
      setState(() {});
    } catch (e) {
      setState(() {

      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send notification for the event: $e')));
    }
  }

  Future<void> _navigateToAppliedEvents() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppliedEvents(),
      ),
    );
    _fetchUserDetails(); // Refresh user details when returning
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
            onPressed: _navigateToAppliedEvents,
            icon: Icon(Icons.app_registration_rounded),
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
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _getEventsBySkills(),
        builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}',style: texStyle(),));
          }

          List<DocumentSnapshot> events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(child: Text('No matching events found',style: texStyle(),));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = events[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              List<String> eventSkills = List<String>.from(data['skills'] ?? []);

              // Find matching skills
              List<String> matchingSkills = _userSkills.where((skill) => eventSkills.contains(skill)).toList();

              return Card(
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
                      Text('Skills Required:', style: appFontStyle(15, texColorDark, FontWeight.bold)),
                      Text(eventSkills.join(', '), style: appFontStyle(15)),
                      SizedBox(height: 10),
                      if (matchingSkills.isNotEmpty)
                        Text('Matching Skills: ${matchingSkills.join(', ')}', style: appFontStyle(15, Colors.green)),
                      Text('Location:', style: appFontStyle(15, texColorDark, FontWeight.bold)),
                      Text('Sub District: ${data['sub_district'] ?? 'N/A'}', style: appFontStyle(15)),
                      Text('District: ${data['district'] ?? 'N/A'}', style: appFontStyle(15)),
                      Divider(),
                      ElevatedButton(
                        onPressed: () {
                          _registerForEvent(document.id, data['user_id']);
                        },
                        child: Text("Apply"),
                      ),
                    ],
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