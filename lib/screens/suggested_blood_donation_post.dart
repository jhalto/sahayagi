import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/applied_blood_post.dart';
import 'package:sahayagi/screens/manage_message.dart';
import 'package:sahayagi/widget/common_widget.dart';
import '../helpers/notification_helper.dart';
import 'message_list_page.dart'; // Make sure this path is correct

class SuggestedBloodPosts extends StatefulWidget {
  const SuggestedBloodPosts({Key? key}) : super(key: key);

  @override
  State<SuggestedBloodPosts> createState() => _SuggestedBloodPostsState();
}

class _SuggestedBloodPostsState extends State<SuggestedBloodPosts> {
  String? _userBloodGroup;
  String? _userDistrict;
  Set<String> _appliedPostIds = {};
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchAppliedBloodPosts();
  }

  Future<void> _fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
      return;
    }

    _currentUserId = user.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      setState(() {
        _userBloodGroup = userDoc['blood_group'];
        _userDistrict = userDoc['district'];
      });
      _fetchAppliedBloodPosts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User document not found')));
    }
  }

  Future<void> _fetchAppliedBloodPosts() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    QuerySnapshot appliedPostsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('applied_blood_posts')
        .get();

    setState(() {
      _appliedPostIds = appliedPostsSnapshot.docs.map((doc) => doc['post_id'] as String).toSet();
    });
  }

  Stream<List<DocumentSnapshot>> _getSuggestedBloodPosts() {
    if (_userBloodGroup == null || _userDistrict == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('blood_donation')
        .where('blood_group', isEqualTo: _userBloodGroup)
        .where('district', isEqualTo: _userDistrict)
        .snapshots()
        .map((querySnapshot) {
      List<DocumentSnapshot> docs = querySnapshot.docs;
      return docs.where((doc) => !_appliedPostIds.contains(doc.id) && doc['user_id'] != _currentUserId).toList();
    });
  }

  Future<void> _applyForBloodPost(String postId, String postOwnerId) async {
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

      // Fetch post owner's device token
      DocumentSnapshot postOwnerDoc = await FirebaseFirestore.instance.collection('users').doc(postOwnerId).get();
      String? postOwnerDeviceToken = postOwnerDoc['device_token'];

      if (postOwnerDeviceToken != null) {
        // Send notification to post owner
        NotificationHelper notificationHelper = NotificationHelper();
        await notificationHelper.sendPushNotification(
          postOwnerDeviceToken,
          'New Blood Post Application',
          'You have a new application for your blood post.',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully applied for the blood post')));

      // Refresh the list of applied blood posts and trigger a rebuild to refresh the suggested blood posts list
      _fetchAppliedBloodPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to apply for the blood post: $e')));
    }
  }

  Future<void> _navigateToAppliedBloodPost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AppliedBloodPosts(),
      ),
    );
    _fetchUserDetails(); // Refresh user details when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text("Suggested Blood Posts", style: appFontStyle(25, texColorLight)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _navigateToAppliedBloodPost();
            },
            icon: Icon(Icons.bloodtype_outlined),
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
      body: _userBloodGroup == null || _userDistrict == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<List<DocumentSnapshot>>(
        stream: _getSuggestedBloodPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          List<DocumentSnapshot> bloodPosts = snapshot.data ?? [];
          if (bloodPosts.isEmpty) {
            return Center(child: Text('No matching blood posts found'));
          }

          return ListView.builder(
            itemCount: bloodPosts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = bloodPosts[index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Card(
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
                      Divider(),
                      ElevatedButton(
                        onPressed: () {
                          _applyForBloodPost(document.id, data['user_id']);
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