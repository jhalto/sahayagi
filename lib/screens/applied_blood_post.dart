import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahayagi/widget/common_widget.dart';

class AppliedBloodPosts extends StatefulWidget {
  const AppliedBloodPosts({Key? key}) : super(key: key);

  @override
  State<AppliedBloodPosts> createState() => _AppliedBloodPostsState();
}

class _AppliedBloodPostsState extends State<AppliedBloodPosts> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Stream<List<DocumentSnapshot>> _getAppliedBloodPosts() {
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('applied_blood_posts')
        .snapshots()
        .asyncMap((snapshot) async {
      List<DocumentSnapshot> appliedPosts = snapshot.docs;
      List<DocumentSnapshot> bloodPosts = [];

      for (var doc in appliedPosts) {
        DocumentSnapshot bloodPost = await FirebaseFirestore.instance
            .collection('blood_donation')
            .doc(doc.id)
            .get();
        bloodPosts.add(bloodPost);
      }

      return bloodPosts;
    });
  }

  Future<void> _removeApplication(String postId) async {
    try {
      // Remove from user's applied_blood_posts collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('applied_blood_posts')
          .doc(postId)
          .delete();

      // Remove from the blood_donation's applications sub-collection
      await FirebaseFirestore.instance
          .collection('blood_donation')
          .doc(postId)
          .collection('applications')
          .doc(user!.uid)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application removed successfully')));

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove application: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Applied Blood Posts", style: appFontStyle(25, texColorLight)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _getAppliedBloodPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          List<DocumentSnapshot> bloodPosts = snapshot.data ?? [];
          if (bloodPosts.isEmpty) {
            return Center(child: Text('No applied blood posts found'));
          }

          return ListView.builder(
            itemCount: bloodPosts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = bloodPosts[index];
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
                        Text('Hospital: ${data['hospital'] ?? 'N/A'}', style: appFontStyle(20, texColorDark, FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Description: ${data['description'] ?? 'No description'}', style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text('Blood Group: ${data['blood_group'] ?? 'No blood group'}', style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text('Phone: ${data['phone'] ?? 'N/A'}', style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text('Location: ${data['location_details'] ?? 'N/A'}', style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text('Operation Date: ${data['operation_date'] != null ? DateFormat.yMd().format((data['operation_date'] as Timestamp).toDate()) : 'N/A'}', style: appFontStyle(15)),
                        SizedBox(height: 10),
                        Text('Last Application Date: ${data['last_application_date'] != null ? DateFormat.yMd().format((data['last_application_date'] as Timestamp).toDate()) : 'N/A'}', style: appFontStyle(15)),
                        ElevatedButton(
                          onPressed: () {
                            _removeApplication(document.id);
                          },
                          child: Text("Remove Application"),
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