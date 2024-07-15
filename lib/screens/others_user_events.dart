import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helpers/notification_helper.dart'; // Ensure this path is correct
import '../widget/common_widget.dart'; // Assuming this is where appFontStyle is defined

class OtherUserEventsScreen extends StatelessWidget {
  final String userId;

  OtherUserEventsScreen({required this.userId});

  Stream<List<DocumentSnapshot>> _fetchUserEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs);
  }

  Future<void> _registerForEvent(String eventId, String eventOwnerId, BuildContext context) async {
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

        // Store notification in Firestore
        await FirebaseFirestore.instance.collection('notifications').add({
          'user_id': eventOwnerId,
          'title': 'New Application',
          'body': 'You have a new application for your event.',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully applied for the event')));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to apply for the event: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _fetchUserEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          List<DocumentSnapshot> events = snapshot.data ?? [];
          if (events.isEmpty) {
            return Center(child: Text('No events found'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = events[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? 'No Title',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      if (data['image_url'] != null)
                        Image.network(data['image_url'], height: 240, width: double.infinity, fit: BoxFit.fill),
                      SizedBox(height: 10),
                      Text(
                        data['description'] ?? 'No Description',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Event date: ${data['event_date'] != null ? (data['event_date'] as Timestamp).toDate().toString() : 'Unknown'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Divider(),
                      ElevatedButton(
                        onPressed: () {
                          _registerForEvent(document.id, data['user_id'], context);
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
