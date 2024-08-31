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
  Stream<List<DocumentSnapshot>> _fetchAppliedBloodPosts() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applied_blood_posts')
        .snapshots()
        .asyncMap((QuerySnapshot appliedBloodPostsSnapshot) async {
      List<DocumentSnapshot> appliedBloodPostsDocs = [];
      for (var doc in appliedBloodPostsSnapshot.docs) {
        DocumentSnapshot bloodPostDoc = await FirebaseFirestore.instance
            .collection('blood_donation')
            .doc(doc.id)
            .get();

        if (bloodPostDoc.exists) {
          appliedBloodPostsDocs.add(bloodPostDoc);
        }
      }
      return appliedBloodPostsDocs;
    });
  }

  Future<void> _removeApplication(String postId) async {
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
          .collection('applied_blood_posts')
          .doc(postId)
          .delete();

      await FirebaseFirestore.instance
          .collection('blood_donation')
          .doc(postId)
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
        title: Text("Applied Blood Posts", style: appFontStyle(25, texColorLight)),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _fetchAppliedBloodPosts(),
        builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          List<DocumentSnapshot> appliedBloodPosts = snapshot.data ?? [];
          if (appliedBloodPosts.isEmpty) {
            return Center(child: Text('No applied blood posts found'));
          }

          return ListView.builder(
            itemCount: appliedBloodPosts.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = appliedBloodPosts[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;

              return Container(
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Posted by: ${data['user_name'] ?? 'Unknown'}',
                          style: appFontStyle(15, texColorDark, FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Hospital: ${data['hospital'] ?? 'N/A'}',
                          style: appFontStyle(20, texColorDark, FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Description: ${data['description'] ?? 'No description'}',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Blood Group: ${data['blood_group'] ?? 'No blood group'}',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Phone: ${data['phone'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Location: ${data['location_details'] ?? 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Operation Date: ${data['operation_date'] != null ? DateFormat.yMd().format((data['operation_date'] as Timestamp).toDate()) : 'N/A'}',
                          style: appFontStyle(15),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Last Application Date: ${data['last_application_date'] != null ? DateFormat.yMd().format((data['last_application_date'] as Timestamp).toDate()) : 'N/A'}',
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