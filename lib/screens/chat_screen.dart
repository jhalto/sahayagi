import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sahayagi/widget/common_widget.dart';

import '../helpers/notification_helper.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;

  const ChatScreen({Key? key, required this.friendId, required this.friendName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final NotificationHelper _notificationHelper = NotificationHelper();
  Future<void> clearConversation(String friendId) async {
    // Mark all messages as deleted for the current user
    final senderMessagesSnapshot = await _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUser!.uid)
        .where('receiverId', isEqualTo: friendId)
        .get();

    for (var doc in senderMessagesSnapshot.docs) {
      await doc.reference.update({
        'deletedFor': FieldValue.arrayUnion([currentUser!.uid]),
      });
    }

    final receiverMessagesSnapshot = await _firestore
        .collection('messages')
        .where('senderId', isEqualTo: friendId)
        .where('receiverId', isEqualTo: currentUser!.uid)
        .get();

    for (var doc in receiverMessagesSnapshot.docs) {
      await doc.reference.update({
        'deletedFor': FieldValue.arrayUnion([currentUser!.uid]),
      });
    }

    setState(() {});
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final messageText = _controller.text;

      // Send the message
      await _firestore.collection('messages').add({
        'text': messageText,
        'senderId': currentUser!.uid,
        'receiverId': widget.friendId,
        'timestamp': FieldValue.serverTimestamp(),
        'deletedFor': [],
      });

      // Clear the text field
      _controller.clear();

      // Check if the friend is currently viewing the chat
      final friendDoc = await _firestore.collection('users').doc(widget.friendId).get();
      final isFriendInChat = friendDoc['inChatWith'] == currentUser!.uid;

      if (!isFriendInChat) {
        // Send a push notification if the friend is not in the chat
        final friendToken = friendDoc['device_token'];
        if (friendToken != null) {
          await _notificationHelper.sendPushNotification(friendToken, 'New Message from ${currentUser!.displayName}', messageText);
        }
      }
    }
  }

  Stream<List<QueryDocumentSnapshot>> _getMessagesStream() {
    final senderMessages = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUser!.uid)
        .where('receiverId', isEqualTo: widget.friendId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    final receiverMessages = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: widget.friendId)
        .where('receiverId', isEqualTo: currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);

    return Rx.combineLatest2<List<QueryDocumentSnapshot>, List<QueryDocumentSnapshot>, List<QueryDocumentSnapshot>>(
        senderMessages, receiverMessages, (sender, receiver) {
      final combined = [...sender, ...receiver];
      combined.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
      return combined;
    });
  }

  @override
  void initState() {
    super.initState();
    _setInChatWith(widget.friendId);
  }

  @override
  void dispose() {
    _setInChatWith(null);
    super.dispose();
  }

  void _setInChatWith(String? friendId) {
    _firestore.collection('users').doc(currentUser!.uid).update({
      'inChatWith': friendId,
    });
  }
  void _showClearConfirmationDialog(String friendId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Conversation'),
        content: Text('Are you sure you want to delete this conversation permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel button
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              clearConversation(friendId); // Perform the delete operation
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  void _showDeleteOptions(BuildContext context, String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete for me'),
                onTap: () {
                  _deleteMessageForMe(messageId);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text('Delete for both'),
                onTap: () {
                  _deleteMessageForBoth(messageId);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteMessageForMe(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'deletedFor': FieldValue.arrayUnion([currentUser!.uid]),
    });
  }

  void _deleteMessageForBoth(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.friendName}',style: texStyle(),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
           _showClearConfirmationDialog(widget.friendId);
          }, icon: Icon(Icons.clear))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _getMessagesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final messageData = message.data() as Map<String, dynamic>;

                    // Check if the necessary fields exist
                    final messageText = messageData.containsKey('text') ? messageData['text'] : '';
                    final isUserMessage = messageData.containsKey('senderId') ? messageData['senderId'] == currentUser!.uid : false;

                    // Check if the message is marked as deleted for the current user
                    final deletedFor = messageData['deletedFor'] ?? [];
                    if (deletedFor.contains(currentUser!.uid)) {
                      return Container(); // Don't display the message if it's deleted for the current user
                    }

                    return GestureDetector(
                      onLongPress: () => _showDeleteOptions(context, message.id),
                      child: Align(
                        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: isUserMessage ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            messageText,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration.collapsed(hintText: 'Type a message'),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}