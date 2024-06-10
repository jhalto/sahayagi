import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahayagi/widget/common_widget.dart';

class SuggestedBloodPosts extends StatefulWidget {
  const SuggestedBloodPosts({Key? key}) : super(key: key);

  @override
  State<SuggestedBloodPosts> createState() => _SuggestedBloodPostsState();
}

class _SuggestedBloodPostsState extends State<SuggestedBloodPosts> {
  String? _userBloodGroup;
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
        _userBloodGroup = userDoc['blood_group'];
        _userDistrict = userDoc['district'];
      });
    } else {
      throw Exception("User document not found");
    }
  }

  Future<List<DocumentSnapshot>> _getSuggestedBloodPosts() async {
    if (_userBloodGroup == null || _userDistrict == null) {
      return [];
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('blood_donation')
        .where('blood_group', isEqualTo: _userBloodGroup)
        .where('district', isEqualTo: _userDistrict)
        .get();

    return querySnapshot.docs;
  }

  Future<void> _applyForBloodPost(String postId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String userName = userDoc['name'] ?? 'Unknown';

      // Adding application details to the 'applications' sub-collection in the specific blood post document
      await FirebaseFirestore.instance
          .collection('blood_donation')
          .doc(postId)
          .collection('applications')
          .doc(user.uid)
          .set({
        'user_id': user.uid,
        'name': userName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Optionally, you can add a reference to this blood post in the user's document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('applied_blood_posts')
          .doc(postId)
          .set({
        'post_id': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully applied for the blood post')));

      // Trigger rebuild to refresh the blood posts list
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to apply for the blood post: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Suggested Blood Posts", style: appFontStyle(25, texColorLight)),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _fetchUserDetailsFuture,
        builder: (context, userDetailsSnapshot) {
          if (userDetailsSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (userDetailsSnapshot.hasError) {
            return Center(child: Text('Something went wrong: ${userDetailsSnapshot.error}'));
          }

          return FutureBuilder<List<DocumentSnapshot>>(
            future: _getSuggestedBloodPosts(),
            builder: (context, bloodPostsSnapshot) {
              if (bloodPostsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (bloodPostsSnapshot.hasError) {
                return Center(child: Text('Something went wrong: ${bloodPostsSnapshot.error}'));
              }

              List<DocumentSnapshot> bloodPosts = bloodPostsSnapshot.data ?? [];
              if (bloodPosts.isEmpty) {
                return Center(child: Text('No matching blood posts found'));
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
                            Text('Phone: ${data['phone'] ?? 'N/A'}', style: appFontStyle(15)),
                            SizedBox(height: 10),
                            Text('Location: ${data['location_details'] ?? 'N/A'}', style: appFontStyle(15)),
                            SizedBox(height: 10),
                            Text('Operation Date: ${data['operation_date'] != null ? DateFormat.yMd().format((data['operation_date'] as Timestamp).toDate()) : 'N/A'}', style: appFontStyle(15)),
                            SizedBox(height: 10),
                            Text('Last Application Date: ${data['last_application_date'] != null ? DateFormat.yMd().format((data['last_application_date'] as Timestamp).toDate()) : 'N/A'}', style: appFontStyle(15)),
                            ElevatedButton(
                              onPressed: () {
                                _applyForBloodPost(document.id);
                              },
                              child: Text("Apply"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}