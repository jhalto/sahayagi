import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentScreen extends StatelessWidget {
  final String postId;

  CommentScreen({required this.postId});

  @override
  Widget build(BuildContext context) {
    // Add your comment screen implementation here
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Center(
        child: Text('Comments for post $postId'),
      ),
    );
  }
}