import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendRequestDetailPage extends StatelessWidget {
  final String requestId;
  final String currentUserId;

  const FriendRequestDetailPage({required this.requestId, required this.currentUserId, Key? key}) : super(key: key);

  Future<void> respondToFriendRequest(BuildContext context, String senderUserId, bool accept) async {
    DocumentReference currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
    DocumentReference senderUserRef = FirebaseFirestore.instance.collection('users').doc(senderUserId);

    if (accept) {
      await currentUserRef.update({
        'friends': FieldValue.arrayUnion([senderUserId])
      });

      await senderUserRef.update({
        'friends': FieldValue.arrayUnion([currentUserId])
      });
    }

    await currentUserRef.update({
      'friendRequests': FieldValue.arrayRemove([senderUserId])
    });

    Navigator.of(context).pop(true); // Close the detail page and return true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Request Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(requestId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found'));
          }

          Map<String, dynamic> requestUserData = snapshot.data!.data() as Map<String, dynamic>;

          String profilePic = requestUserData['profilePic'] ?? ''; // Provide a default value
          String name = requestUserData['name'] ?? 'Unknown'; // Provide a default value
          String email = requestUserData['email'] ?? 'No email'; // Provide a default value
          String age = requestUserData['age'] ?? 'N/A';
          String bloodGroup = requestUserData['blood_group'] ?? 'N/A';
          List<String> skills = List<String>.from(requestUserData['skills'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                  child: profilePic.isEmpty ? Icon(Icons.person, size: 50) : null,
                ),
                SizedBox(height: 20),
                Text('Name: $name', style: TextStyle()),
                SizedBox(height: 10),
                Text('Email: $email', style: TextStyle()),
                SizedBox(height: 10),
                Text('Age: $age', style: TextStyle()),
                SizedBox(height: 10),
                Text('Blood Group: $bloodGroup', style: TextStyle()),
                SizedBox(height: 10),
                Text('Skills: ${skills.join(', ')}', style: TextStyle()),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => respondToFriendRequest(context, requestId, true),
                      child: Text('Accept'),
                    ),
                    ElevatedButton(
                      onPressed: () => respondToFriendRequest(context, requestId, false),
                      child: Text('Decline'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}