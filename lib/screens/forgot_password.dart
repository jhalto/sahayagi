import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sahayagi/widget/common_widget.dart'; // Assuming this is where appFontStyle is defined

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController _emailController = TextEditingController();

  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent. Please check your email.')),
      );
      Navigator.pop(context); // Optionally, navigate back after sending the email
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else {
        message = 'Failed to send reset email. Please try again later.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Please enter your email to continue",
                style: appFontStyle(20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Form(
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Please Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (_emailController.text.isNotEmpty) {
                    _sendPasswordResetEmail(_emailController.text);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter an email address.')),
                    );
                  }
                },
                child: Text("Next"),
              )
            ],
          ),
        ),
      ),
    );
  }
}