import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahayagi/widget/common_widget.dart';

class ViewApplicants extends StatefulWidget {
  final String postId;
  final String postTitle;

  const ViewApplicants({required this.postId, required this.postTitle, Key? key}) : super(key: key);

  @override
  State<ViewApplicants> createState() => _ViewApplicantsState();
}

class _ViewApplicantsState extends State<ViewApplicants> {
  Stream<List<DocumentSnapshot>> _getApplicants() {
    return FirebaseFirestore.instance
        .collection('blood_donation')
        .doc(widget.postId)
        .collection('applications')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.postTitle} Applicants", style: appFontStyle(25, texColorLight)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _getApplicants(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          List<DocumentSnapshot> applicants = snapshot.data ?? [];
          if (applicants.isEmpty) {
            return Center(child: Text('No applicants found'));
          }

          return ListView.builder(
            itemCount: applicants.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = applicants[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text(data['name'] ?? 'Unknown', style: appFontStyle(18, texColorDark, FontWeight.bold)),
                  subtitle: Text('Applied on: ${DateFormat.yMd().format((data['timestamp'] as Timestamp).toDate())}', style: appFontStyle(15)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}