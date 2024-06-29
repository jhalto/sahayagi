import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SendMessagePage extends StatefulWidget {
  final String friendId;
  final String friendName;

  const SendMessagePage({required this.friendId, required this.friendName, Key? key}) : super(key: key);

  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final TextEditingController _messageController = TextEditingController();

  Future<void> sendMessage(String message) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentReference currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      DocumentReference friendUserRef = FirebaseFirestore.instance.collection('users').doc(widget.friendId);

      // Create a message object
      Map<String, dynamic> messageData = {
        'senderId': currentUser.uid,
        'receiverId': widget.friendId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save the message in Firestore
      await FirebaseFirestore.instance.collection('messages').add(messageData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message sent to ${widget.friendName}')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Message to ${widget.friendName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String message = _messageController.text;
                if (message.isNotEmpty) {
                  sendMessage(message);
                }
              },
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}