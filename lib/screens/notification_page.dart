import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widget/common_widget.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Notifications", style: appFontStyle(25, texColorLight)),
        ),
        body: Center(child: Text("User not logged in", style: appFontStyle(20, texColorDark))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: appFontStyle(25, texColorLight)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('user_id', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}', style: appFontStyle(20, texColorDark)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications', style: texStyle()));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title'] ?? 'No title', style: texStyle()),
                subtitle: Text(data['body'] ?? 'No body', style: texStyle()),
                trailing: Text(data['timestamp']?.toDate().toString() ?? 'No timestamp', style: texStyle()),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}