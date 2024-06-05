import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widget/common_widget.dart';

class AppliedUsersInEvent extends StatelessWidget {
  final String eventId;

  const AppliedUsersInEvent({Key? key, required this.eventId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchAppliedUsers() async {
    QuerySnapshot appliedUsersSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('applications')
        .get();

    List<Map<String, dynamic>> appliedUsersDocs = [];
    for (var doc in appliedUsersSnapshot.docs) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(doc.id)
          .get();
      appliedUsersDocs.add({
        'document': userDoc,
        'appliedUserId': doc.id,
      });
    }

    return appliedUsersDocs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Applied Users", style: appFontStyle(25, texColorLight)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAppliedUsers(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users have applied for this event'));
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.map((Map<String, dynamic> data) {
              DocumentSnapshot document = data['document'];
              Map<String, dynamic> userData = document.data()! as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${userData['name'] ?? 'Unknown'}', style: appFontStyle(15, texColorDark, FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Email: ${userData['email'] ?? 'Unknown'}', style: appFontStyle(15)),
                      const SizedBox(height: 10),
                      Text('Phone: ${userData['phone'] ?? 'Unknown'}', style: appFontStyle(15)),
                      // Add more user details here if needed
                    ],
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